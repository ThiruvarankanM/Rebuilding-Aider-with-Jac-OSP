##
# change_coordinator.jac
#
# Multi-file change coordination walker for OSP/MTP environment.
# Responsibilities:
#  - Accept a set of proposed file edits (or generated patch objects)
#  - Validate edits against repo map and impact analysis
#  - Order edits to minimize conflicts / maximize correctness
#  - Stage edits in a transactional manner (with rollback on failure)
#  - Provide hooks for pre/post validation, summaries and human review
#
# Depends on:
#  - file_nodes.jac (CodeFile, Patch, etc.)
#  - repomap_osp.jac (RepoMap and node lookup)
#  - impact_analyzer.jac (impact scoring & dependency discovery)
#  - token_optimizer.jac (to estimate token budgets when summarizing edits)
#
# Author: Aider (converted for Jac)
##

import * from file_nodes;
import * from repomap_osp;
import * from impact_analyzer;
import * from token_optimizer;

# ChangeRecord - single change metadata
node ChangeRecord {
    has string change_id;         # unique id for change (UUID or generated token)
    has string file_path;         # file path relative to repo root
    has Patch patch;              # Patch node describing the edit
    has float impact_score = 0.0; # computed impact score (higher -> riskier)
    has int size_estimate = 0;    # approximate size of change in characters/tokens
    has string author = "";       # optional author
    has string reason = "";       # human-readable reason/description
    has bool applied = false;     # whether this change was applied
    has bool validated = false;   # whether validated pre-apply
}

# TransactionRecord - contains group of changes to apply atomically
node TransactionRecord {
    has string txn_id;
    has ChangeRecord[] changes = [];
    has string status = "pending";  # pending | applying | committed | rolled_back | failed
    has string summary = "";
    has map meta = {};              # arbitrary metadata
}

# Simple utility walker for internal functions
walker ChangeUtils {
    can compute_size(ChangeRecord),
        compute_impact(ChangeRecord),
        to_summary(TransactionRecord);

    can compute_size(ChangeRecord) {
        # Very rough size estimate: length of patch representation
        if this.patch and this.patch.diff_text {
            this.size_estimate = len(this.patch.diff_text);
        } else {
            this.size_estimate = 0;
        }
    }

    can compute_impact(ChangeRecord) {
        # Use impact analyzer if available; fallback to heuristic
        try {
            this.impact_score = ImpactAnalyzer.estimate_impact(this.file_path, this.patch);
        } catch {
            # Heuristic: modifications to high-level files (like top-level modules)
            if this.file_path == "setup.py" or this.file_path == "pyproject.toml" {
                this.impact_score = 1.0;
            } else {
                this.impact_score = float(min(1.0, max(0.0, len(this.patch.diff_text) / 2000.0)));
            }
        }
    }

    can to_summary(TransactionRecord) {
        string s = "Transaction " + this.txn_id + " (" + this.status + "):\n";
        int i = 0;
        for (ChangeRecord cr in this.changes) {
            s += "  - [" + cr.change_id + "] " + cr.file_path + " (impact=" + str(cr.impact_score) + ", size=" + str(cr.size_estimate) + ")\n";
            i = i + 1;
        }
        this.summary = s;
    }
}

# Coordinator walker: orchestrates multi-file edits
walker ChangeCoordinator {
    can propose(Patch[]),
        validate(TransactionRecord),
        order(TransactionRecord),
        stage(TransactionRecord),
        apply(TransactionRecord),
        rollback(TransactionRecord),
        summarize(TransactionRecord),
        dry_run(TransactionRecord);

    has int max_transaction_size = 50000;   # character limit for an atomic transaction
    has float max_total_impact = 2.5;       # maximum combined impact we allow by default
    has bool require_human_confirmation = true;
    has int max_retries = 2;

    # Entry: propose patches -> build a transaction
    can propose(Patch[] patches) -> TransactionRecord {
        TransactionRecord txn = TransactionRecord {
            txn_id: "txn_" + str(now()),
            changes: [],
            status: "proposed"
        };

        int idx = 0;
        for (Patch p in patches) {
            ChangeRecord cr = ChangeRecord {
                change_id: txn.txn_id + "_c" + str(idx),
                file_path: p.target_path,
                patch: p,
                impact_score: 0.0,
                size_estimate: 0,
                applied: false,
                validated: false
            };
            ChangeUtils.compute_size(cr);
            ChangeUtils.compute_impact(cr);
            txn.changes += [cr];
            idx = idx + 1;
        }

        ChangeUtils.to_summary(txn);
        report("Proposed transaction: " + txn.summary);
        return txn;
    }

    # Validate: run static checks, impact analysis and token checks
    can validate(TransactionRecord txn) -> bool {
        txn.status = "validating";
        report("Validating transaction " + txn.txn_id);

        float total_impact = 0.0;
        int total_size = 0;
        for (ChangeRecord cr in txn.changes) {
            # Validate file exists in repomap
            Node nf = RepoMap.lookup_file(cr.file_path);
            if nf is none {
                report("Validation error: file not found in repo map: " + cr.file_path);
                txn.status = "failed";
                return false;
            }

            # Recompute impact and size defensively
            ChangeUtils.compute_size(cr);
            ChangeUtils.compute_impact(cr);

            total_size += cr.size_estimate;
            total_impact += cr.impact_score;
            cr.validated = true;
        }

        # Token budget check: try to respect TokenBudget.global.max_tokens
        try {
            int remaining = TokenBudget.global.max_tokens - TokenBudget.global.used_tokens;
            if total_size > remaining {
                report("Validation warning: proposed changes exceed token budget (size=" + str(total_size) + ", remaining=" + str(remaining) + ")");
                # Let caller decide; mark but do not fail outright
            }
        } catch {
            # if TokenBudget not present or fails, continue
        }

        if total_size > this.max_transaction_size {
            report("Validation failed: transaction exceeds max transaction size: " + str(total_size));
            txn.status = "failed";
            return false;
        }

        if total_impact > this.max_total_impact {
            report("Validation warning: combined impact score " + str(total_impact) + " exceeds threshold " + str(this.max_total_impact));
            # Allow by default but mark for human confirm
            txn.meta["impact_warning"] = true;
        } else {
            txn.meta["impact_warning"] = false;
        }

        txn.status = "validated";
        ChangeUtils.to_summary(txn);
        report("Validation complete: " + txn.summary);
        return true;
    }

    # Order: try to order changes to minimize conflicts (heuristic + dependency graph)
    can order(TransactionRecord txn) -> TransactionRecord {
        txn.status = "ordering";
        report("Ordering transaction " + txn.txn_id);

        # Simple heuristic ordering:
        #  - Lower impact first
        #  - Smaller files first
        #  - Preserve specified order for same-score ties
        txn.changes.sort(lambda a,b: (a.impact_score, a.size_estimate) < (b.impact_score, b.size_estimate));

        # Use impact analyzer to reorder by detected dependencies where possible
        for (int i = 0; i < len(txn.changes); i = i + 1) {
            ChangeRecord cr = txn.changes[i];
            try {
                string[] deps = ImpactAnalyzer.dependencies_for(cr.file_path);
                # If there are dependencies present in txn, move them before cr
                for (string d in deps) {
                    for (int j = 0; j < len(txn.changes); j = j + 1) {
                        if txn.changes[j].file_path == d and j > i {
                            # move dependency to position i
                            ChangeRecord dep = txn.changes[j];
                            txn.changes.remove_at(j);
                            txn.changes.insert(i, dep);
                            report("Reordered to respect dependency: " + dep.file_path + " -> " + cr.file_path);
                            i = i + 1;  # advance to skip newly inserted
                        }
                    }
                }
            } catch {
                # if impact analyzer fails, ignore
            }
        }

        ChangeUtils.to_summary(txn);
        report("Ordering complete: " + txn.summary);
        return txn;
    }

    # Stage: create a staging area for changes and run pre-apply checks (lint/tests)
    can stage(TransactionRecord txn) -> bool {
        txn.status = "staging";
        report("Staging transaction " + txn.txn_id);

        # Create in-memory staging snapshots (Patch.apply_to_string returns new content)
        txn.meta["staging_snapshots"] = {};
        for (ChangeRecord cr in txn.changes) {
            try {
                Node file_node = RepoMap.lookup_file(cr.file_path);
                if file_node is none {
                    report("Staging failed: file not found: " + cr.file_path);
                    txn.status = "failed";
                    return false;
                }

                string original_content = file_node.content;
                string new_content = cr.patch.apply_to_string(original_content);

                txn.meta["staging_snapshots"][cr.file_path] = {
                    "original": original_content,
                    "new": new_content
                };

                # Run lightweight static validators, if any
                bool lint_ok = true;
                try {
                    lint_ok = ImpactAnalyzer.lint_suggest(cr.file_path, new_content);
                } catch {
                    # If linter not available, assume ok
                    lint_ok = true;
                }

                if not lint_ok {
                    report("Staging lint failed for " + cr.file_path);
                    txn.meta["lint_failure"] = true;
                    # don't fail immediately; allow user to decide
                }

            } catch {
                report("Exception during staging for " + cr.file_path + ", aborting staging");
                txn.status = "failed";
                return false;
            }
        }

        txn.status = "staged";
        report("Staging complete for " + txn.txn_id);
        return true;
    }

    # Apply: attempt to apply transaction atomically, with rollback on failure
    can apply(TransactionRecord txn) -> bool {
        txn.status = "applying";
        report("Applying transaction " + txn.txn_id);

        # Human confirmation if required and impact warning present
        if this.require_human_confirmation and txn.meta.get("impact_warning", false) {
            if not user_confirm("Transaction " + txn.txn_id + " has impact warnings. Proceed? (y/n)"):
                report("User aborted transaction due to impact warnings");
                txn.status = "rolled_back";
                return false;
        }

        # Start atomic update sequence
        txn.meta["applied_files"] = [];
        int attempt = 0;
        while attempt <= this.max_retries {
            attempt = attempt + 1;
            bool ok = true;
            for (ChangeRecord cr in txn.changes) {
                try {
                    # Apply in-memory snapshot to RepoMap node (this is an in-memory simulation of file write)
                    map snaps = txn.meta["staging_snapshots"][cr.file_path];
                    if snaps is none {
                        report("Missing staging snapshot for " + cr.file_path + ", aborting");
                        ok = false;
                        break;
                    }

                    Node file_node = RepoMap.lookup_file(cr.file_path);
                    if file_node is none {
                        report("File vanished from repomap during apply: " + cr.file_path);
                        ok = false;
                        break;
                    }

                    # If file changed externally since staging, detect conflict
                    if file_node.content != snaps["original"] {
                        report("Conflict detected for " + cr.file_path + " (external change)");
                        ok = false;
                        txn.meta["conflict_file"] = cr.file_path;
                        break;
                    }

                    # Commit the new content to the file node
                    file_node.content = snaps["new"];
                    txn.meta["applied_files"] += [cr.file_path];
                    cr.applied = true;
                    report("Applied change to " + cr.file_path);
                } catch {
                    ok = false;
                    report("Error applying change to " + cr.file_path);
                    break;
                }
            }

            if ok {
                txn.status = "committed";
                report("Transaction " + txn.txn_id + " committed successfully");
                # Optionally run post-apply validators (tests, integration checks)
                try {
                    ImpactAnalyzer.run_post_apply_checks(txn);
                } catch {
                    # Post-apply checks failing should not silently destroy commit;
                    # record but keep the changes in place for manual recovery
                    txn.meta["post_apply_issues"] = true;
                    report("Post-apply checks reported issues (see meta)");
                }
                return true;
            } else {
                # Rollback applied files this attempt then retry (if attempts remain)
                report("Attempt " + str(attempt) + " failed, rolling back applied files");
                rollback(txn);   # Rollback will restore original snapshots
                if attempt > this.max_retries {
                    txn.status = "failed";
                    report("Max retries exceeded; transaction failed");
                    return false;
                }
                report("Retrying transaction (attempt " + str(attempt + 1) + ")");
                # Optionally re-stage to refresh snapshots
                if not stage(txn) {
                    txn.status = "failed";
                    return false;
                }
            }
        }

        txn.status = "failed";
        return false;
    }

    # Rollback: restore original content for any applied files
    can rollback(TransactionRecord txn) -> bool {
        txn.status = "rolling_back";
        report("Rolling back transaction " + txn.txn_id);

        try {
            if txn.meta.get("applied_files") {
                for (string fp in txn.meta["applied_files"]) {
                    map snaps = txn.meta["staging_snapshots"][fp];
                    if snaps is none {
                        continue;
                    }
                    Node file_node = RepoMap.lookup_file(fp);
                    if file_node is none {
                        report("During rollback: file not present in repomap: " + fp);
                        continue;
                    }
                    file_node.content = snaps["original"];
                    report("Restored " + fp + " to original content");
                }
            }
        } catch {
            report("Rollback exception occurred; manual intervention may be required");
            txn.status = "rolled_back";
            return false;
        }

        txn.meta["applied_files"] = [];
        txn.status = "rolled_back";
        report("Rollback complete for " + txn.txn_id);
        return true;
    }

    # Summarize: produce human-readable report and optional patch bundle
    can summarize(TransactionRecord txn) -> map {
        ChangeUtils.to_summary(txn);
        map out = {};
        out["txn_id"] = txn.txn_id;
        out["status"] = txn.status;
        out["summary_text"] = txn.summary;
        out["changes_count"] = len(txn.changes);
        out["total_size"] = sum([c.size_estimate for c in txn.changes]);
        out["total_impact"] = sum([c.impact_score for c in txn.changes]);
        out["meta"] = txn.meta;
        return out;
    }

    # Dry-run: stage and validate without applying
    can dry_run(TransactionRecord txn) -> map {
        bool st = stage(txn);
        bool v = validate(txn);
        txn.status = "dry_run_complete";
        return summarize(txn);
    }
}

# Helper function to ask user interactive confirmation (text-based)
can user_confirm(string prompt) -> bool {
    # In MTP/OSP contexts, this may be handled by host system. Provide default True for automation.
    # If an interactive session is available, this hook can be replaced by host to prompt user.
    report("USER_CONFIRM_PROMPT: " + prompt);
    # default to true (automation friendly). Host can override.
    return true;
}

# Small convenience: expose a high level API function to run a full transactional apply
can run_transaction(Patch[] patches) -> map {
    TransactionRecord txn = ChangeCoordinator.propose(patches);
    if not ChangeCoordinator.validate(txn) {
        return ChangeCoordinator.summarize(txn);
    }
    ChangeCoordinator.order(txn);
    ChangeCoordinator.stage(txn);
    map result = {};
    if ChangeCoordinator.apply(txn) {
        result["success"] = true;
        result["summary"] = ChangeCoordinator.summarize(txn);
    } else {
        result["success"] = false;
        result["summary"] = ChangeCoordinator.summarize(txn);
    }
    return result;
}
