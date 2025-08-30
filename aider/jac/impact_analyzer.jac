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
    has list<str> affected_files = [];
    has list<str> affected_functions = [];
    has list<str> affected_classes = [];
    has list<str> dependency_chain = [];
}

walker ImpactAnalyzer {
    has string proposed_change;       # e.g., "Refactor function X"
    has list<ImpactReport> reports = [];

    # Main entry point
    can analyze(RepoMap repo, string change) -> list<ImpactReport> {
        this.proposed_change = change;
        this.reports = [];
        visit repo;
        return this.reports;
    }

    # When visiting a file
    can on_enter CodeFile {
        if this.proposed_change in this.filename or ("content" in this and this.proposed_change in this.content) {
            report = spawn ImpactReport();
            report.change_summary = "Change affects file: " + this.filename;
            report.affected_files += [this.filename];
            this.reports += [report];
        }
    }

    # When visiting a function
    can on_enter FunctionNode {
        if this.proposed_change in this.name or ("body" in this and this.proposed_change in this.body) {
            report = spawn ImpactReport();
            report.change_summary = "Change affects function: " + this.name;
            report.affected_functions += [this.name];
            if "file" in this:
                report.affected_files += [this.file];
            this.reports += [report];
        }
    }

    # When visiting a class
    can on_enter ClassNode {
        if this.proposed_change in this.name or ("body" in this and this.proposed_change in this.body) {
            report = spawn ImpactReport();
            report.change_summary = "Change affects class: " + this.name;
            report.affected_classes += [this.name];
            if "file" in this:
                report.affected_files += [this.file];
            this.reports += [report];
        }
    }

    # When visiting imports
    can on_enter ImportNode {
        if "imported_file" in this and this.proposed_change in this.imported_file {
            report = spawn ImpactReport();
            report.change_summary = "Dependency impacted via import: " + this.imported_file;
            report.dependency_chain += [this.imported_file];
            if "file" in this:
                report.affected_files += [this.file];
            this.reports += [report];
        }
    }

    # Summarize reports
    can summarize() -> string {
        string result = "===== Change Impact Report =====\n"
        for r in this.reports {
            result += "-> " + r.change_summary + "\n"
            if len(r.affected_files) > 0 {
                result += "   Files: " + str.join(r.affected_files, ", ") + "\n"
            }
            if len(r.affected_functions) > 0 {
                result += "   Functions: " + str.join(r.affected_functions, ", ") + "\n"
            }
            if len(r.affected_classes) > 0 {
                result += "   Classes: " + str.join(r.affected_classes, ", ") + "\n"
            }
            if len(r.dependency_chain) > 0 {
                result += "   Dependencies: " + str.join(r.dependency_chain, ", ") + "\n"
            }
        }
        return result
    }
}
