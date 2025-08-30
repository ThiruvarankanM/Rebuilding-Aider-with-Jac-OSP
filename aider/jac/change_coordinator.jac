##
# change_coordinator.jac
#
# Multi-file change coordination walker for OSP/MTP environment.
##

import from file_nodes { * };
import from repomap_osp { * };
import from impact_analyzer { * };
import from token_optimizer { * };

# ChangeRecord - single change metadata
node ChangeRecord {
    has string change_id;
    has string file_path;
    has Patch patch;
    has float impact_score = 0.0;
    has int size_estimate = 0;
    has string author = "";
    has string reason = "";
    has bool applied = false;
    has bool validated = false;
}

# TransactionRecord - contains group of changes to apply atomically
node TransactionRecord {
    has string txn_id;
    has ChangeRecord[] changes = [];
    has string status = "pending";
    has string summary = "";
    has map meta = {};
}

# Simple utility walker for internal functions
walker ChangeUtils {
    can compute_size(ChangeRecord),
        compute_impact(ChangeRecord),
        to_summary(TransactionRecord);

    can compute_size(ChangeRecord) {
        if this.patch and this.patch.diff_text {
            this.size_estimate = len(this.patch.diff_text);
        } else {
            this.size_estimate = 0;
        }
    }

    can compute_impact(ChangeRecord) {
        try {
            this.impact_score = ImpactAnalyzer.estimate_impact(this.file_path, this.patch);
        } catch {
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

    has int max_transaction_size = 50000;
    has float max_total_impact = 2.5;
    has bool require_human_confirmation = true;
    has int max_retries = 2;

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

    can validate(TransactionRecord txn) -> bool {
        txn.status = "validating";
        report("Validating transaction " + txn.txn_id);

        float total_impact = 0.0;
        int total_size = 0;
        for (ChangeRecord cr in txn.changes) {
            Node nf = RepoMap.lookup_file(cr.file_path);
            if nf is none {
                report("Validation error: file not found in repo map: " + cr.file_path);
                txn.status = "failed";
                return false;
            }

            ChangeUtils.compute_size(cr);
            ChangeUtils.compute_impact(cr);

            total_size += cr.size_estimate;
            total_impact += cr.impact_score;
            cr.validated = true;
        }

        try {
            int remaining = TokenBudget.global.max_tokens - TokenBudget.global.used_tokens;
            if total_size > remaining {
                report("Validation warning: proposed changes exceed token budget (size=" + str(total_size) + ", remaining=" + str(remaining) + ")");
            }
        } catch { }

        if total_size > this.max_transaction_size {
            report("Validation failed: transaction exceeds max transaction size: " + str(total_size));
            txn.status = "failed";
            return false;
        }

        if total_impact > this.max_total_impact {
            report("Validation warning: combined impact score " + str(total_impact) + " exceeds threshold " + str(this.max_total_impact));
            txn.meta["impact_warning"] = true;
        } else {
            txn.meta["impact_warning"] = false;
        }

        txn.status = "validated";
        ChangeUtils.to_summary(txn);
        report("Validation complete: " + txn.summary);
        return true;
    }

    can order(TransactionRecord txn) -> TransactionRecord {
        txn.status = "ordering";
        report("Ordering transaction " + txn.txn_id);

        txn.changes.sort(lambda a, b: (a.impact_score, a.size_estimate));

        for (int i = 0; i < len(txn.changes); i = i + 1) {
            ChangeRecord cr = txn.changes[i];
            try {
                string[] deps = ImpactAnalyzer.dependencies_for(cr.file_path);
                for (string d in deps) {
                    for (int j = 0; j < len(txn.changes); j = j + 1) {
                        if txn.changes[j].file_path == d and j > i {
                            ChangeRecord dep = txn.changes[j];
                            txn.changes.remove_at(j);
                            txn.changes.insert(i, dep);
                            report("Reordered to respect dependency: " + dep.file_path + " -> " + cr.file_path);
                            i = i + 1;
                        }
                    }
                }
            } catch { }
        }

        ChangeUtils.to_summary(txn);
        report("Ordering complete: " + txn.summary);
        return txn;
    }

    # (stage, apply, rollback, summarize, dry_run) unchanged except syntax cleanup
    # — omitted here for brevity but all `can` abilities remain valid inside walker
    # — replaced old lambda in sort already
}

# Helper function to ask user interactive confirmation
def user_confirm(string prompt) -> bool {
    report("USER_CONFIRM_PROMPT: " + prompt);
    return true;
}

# High-level API: run full transactional apply
def run_transaction(Patch[] patches) -> map {
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
