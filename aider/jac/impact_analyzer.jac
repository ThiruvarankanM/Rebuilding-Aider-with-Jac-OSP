# impact_analyzer.jac
# --------------------------------------------------
# Module: Impact Analyzer
# Purpose: Analyze the impact of a proposed change across files,
#          functions, classes, and dependencies in the RepoMap.
# --------------------------------------------------

import { RepoMap, CodeFile, FunctionNode, ClassNode, ImportNode } from "repomap_osp.jac"
import { SpatialGraph } from "spatial_graph.jac"

node ImpactReport {
    has string change_summary;
    has list<str> affected_files;
    has list<str> affected_functions;
    has list<str> affected_classes;
    has list<str> dependency_chain;
}

walker ImpactAnalyzer {
    has string proposed_change;       # e.g., "Refactor function X"
    has list<ImpactReport> reports;

    can init {
        reports = [];
    }

    # Main entry point
    can analyze(RepoMap repo, string change) -> list<ImpactReport> {
        proposed_change = change;
        reports = [];

        visit repo;
        return reports;
    }

    # When visiting a file, check if it’s impacted
    can on_enter CodeFile {
        if proposed_change in this.name or proposed_change in this.content {
            report = spawn ImpactReport();
            report.change_summary = "Change affects file: " + this.name;
            report.affected_files.append(this.name);
            reports.append(report);
        }
    }

    # When visiting a function, check if it’s impacted
    can on_enter FunctionNode {
        if proposed_change in this.name or proposed_change in this.body {
            report = spawn ImpactReport();
            report.change_summary = "Change affects function: " + this.name;
            report.affected_functions.append(this.name);
            report.affected_files.append(this.file);
            reports.append(report);
        }
    }

    # When visiting a class, check if it’s impacted
    can on_enter ClassNode {
        if proposed_change in this.name or proposed_change in this.body {
            report = spawn ImpactReport();
            report.change_summary = "Change affects class: " + this.name;
            report.affected_classes.append(this.name);
            report.affected_files.append(this.file);
            reports.append(report);
        }
    }

    # When visiting imports, propagate dependency chain
    can on_enter ImportNode {
        if proposed_change in this.imported_file {
            report = spawn ImpactReport();
            report.change_summary = "Dependency impacted via import: " + this.imported_file;
            report.dependency_chain.append(this.imported_file);
            report.affected_files.append(this.file);
            reports.append(report);
        }
    }

    # Collect reports at the end
    can summarize() -> str {
        result = "===== Change Impact Report =====\n";
        for r in reports {
            result += "-> " + r.change_summary + "\n";
            if len(r.affected_files) > 0:
                result += "   Files: " + ", ".join(r.affected_files) + "\n";
            if len(r.affected_functions) > 0:
                result += "   Functions: " + ", ".join(r.affected_functions) + "\n";
            if len(r.affected_classes) > 0:
                result += "   Classes: " + ", ".join(r.affected_classes) + "\n";
            if len(r.dependency_chain) > 0:
                result += "   Dependencies: " + ", ".join(r.dependency_chain) + "\n";
        }
        return result;
    }
}
