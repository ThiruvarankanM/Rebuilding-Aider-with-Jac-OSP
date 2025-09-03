# ultra_fast_scanner_v2.jac
# High-speed repository scanning with OSP optimization

walker UltraFastScanner {
    has scan_cache: dict = {};
    has file_index: dict = {};
    has performance_stats: dict = {};
    
    def init_scanner() {
        self.scan_cache = {};
        self.file_index = {};
        self.performance_stats = {
            'files_scanned': 0,
            'cache_hits': 0,
            'patterns_found': 0
        };
        print("Ultra-fast scanner initialized");
    }

    # Ultra-fast directory scan with caching
    def scan_directory_ultra_fast(directory_path: str) -> dict {
        # Check cache first
        cache_key = "dir_scan_" + directory_path;
        if cache_key in self.scan_cache {
            self.performance_stats['cache_hits'] = self.performance_stats['cache_hits'] + 1;
            return self.scan_cache[cache_key];
        }
        
        scan_results = {
            'directory': directory_path,
            'total_files': 0,
            'scanned_files': 0,
            'file_types': {},
            'files_by_extension': {},
            'file_details': []
        };
        
        # Simulate scanning files (in real implementation, use os.walk)
        simulated_files = [
            directory_path + "/main.py",
            directory_path + "/utils.py", 
            directory_path + "/config.jac",
            directory_path + "/test_file.py"
        ];
        
        scan_results['total_files'] = len(simulated_files);
        
        for file_path in simulated_files {
            if self.should_include_file(file_path) {
                file_info = self.analyze_file_fast(file_path);
                if file_info {
                    scan_results['file_details'].append(file_info);
                    scan_results['scanned_files'] = scan_results['scanned_files'] + 1;
                    
                    # Update counters
                    file_type = file_info['type'];
                    if file_type not in scan_results['file_types'] {
                        scan_results['file_types'][file_type] = 0;
                    }
                    scan_results['file_types'][file_type] = scan_results['file_types'][file_type] + 1;
                }
            }
        }
        
        # Cache results
        self.scan_cache[cache_key] = scan_results;
        self.performance_stats['files_scanned'] = self.performance_stats['files_scanned'] + scan_results['scanned_files'];
        
        return scan_results;
    }

    # Check if file should be included
    def should_include_file(file_path: str) -> bool {
        # Check for valid extensions
        valid_extensions = ['.py', '.jac', '.js', '.ts'];
        
        for ext in valid_extensions {
            if file_path.endswith(ext) {
                return True;
            }
        }
        
        return False;
    }

    # Fast file analysis
    def analyze_file_fast(file_path: str) -> dict {
        cache_key = "file_" + file_path;
        if cache_key in self.file_index {
            return self.file_index[cache_key];
        }
        
        file_info = {
            'path': file_path,
            'name': '',
            'extension': '',
            'type': 'unknown',
            'lines': 0,
            'functions': 0,
            'classes': 0
        };
        
        # Extract filename
        if '/' in file_path {
            file_info['name'] = file_path.split('/')[-1];
        } else {
            file_info['name'] = file_path;
        }
        
        # Extract extension
        if '.' in file_info['name'] {
            file_info['extension'] = '.' + file_info['name'].split('.')[-1];
        }
        
        # Determine type
        file_info['type'] = self.determine_file_type(file_info['extension']);
        
        # Simulate content analysis
        simulated_content = "# Sample content\nclass Example:\n    def method(self):\n        pass\n";
        file_info['lines'] = len(simulated_content.split('\n'));
        file_info['functions'] = self.count_functions_fast(simulated_content);
        file_info['classes'] = self.count_classes_fast(simulated_content);
        
        # Cache the result
        self.file_index[cache_key] = file_info;
        
        return file_info;
    }

    # Determine file type
    def determine_file_type(extension: str) -> str {
        if extension == '.py' {
            return 'python';
        } elif extension == '.jac' {
            return 'jac';
        } elif extension == '.js' {
            return 'javascript';
        } elif extension == '.ts' {
            return 'typescript';
        } else {
            return 'unknown';
        }
    }

    # Count functions quickly
    def count_functions_fast(content: str) -> int {
        function_count = 0;
        lines = content.split('\n');
        
        for line in lines {
            stripped = line.strip();
            if stripped.startswith('def ') or stripped.startswith('function ') {
                function_count = function_count + 1;
            }
        }
        
        return function_count;
    }

    # Count classes quickly
    def count_classes_fast(content: str) -> int {
        class_count = 0;
        lines = content.split('\n');
        
        for line in lines {
            stripped = line.strip();
            if stripped.startswith('class ') or stripped.startswith('walker ') or stripped.startswith('node ') {
                class_count = class_count + 1;
            }
        }
        
        return class_count;
    }

    # Find files by pattern
    def find_files_by_pattern(pattern: str, scan_results: dict) -> list {
        matching_files = [];
        file_details = scan_results['file_details'];
        
        for file_info in file_details {
            file_path = file_info['path'];
            file_name = file_info['name'];
            
            if pattern in file_path or pattern in file_name or pattern == file_info['extension'] {
                matching_files.append(file_info);
            }
        }
        
        self.performance_stats['patterns_found'] = self.performance_stats['patterns_found'] + len(matching_files);
        
        return matching_files;
    }

    # Generate scan summary
    def generate_scan_summary(scan_results: dict) -> dict {
        summary = {
            'total_files': scan_results['total_files'],
            'scanned_files': scan_results['scanned_files'],
            'file_types': scan_results['file_types'],
            'top_insights': [],
            'recommendations': []
        };
        
        # Generate insights
        file_types = scan_results['file_types'];
        if file_types {
            max_count = 0;
            top_type = 'unknown';
            
            for file_type in file_types {
                count = file_types[file_type];
                if count > max_count {
                    max_count = count;
                    top_type = file_type;
                }
            }
            
            summary['top_insights'].append("Primary language: " + top_type + " (" + str(max_count) + " files)");
        }
        
        # Calculate total functions and classes
        total_functions = 0;
        total_classes = 0;
        
        for file_info in scan_results['file_details'] {
            total_functions = total_functions + file_info['functions'];
            total_classes = total_classes + file_info['classes'];
        }
        
        if total_functions > 0 {
            summary['top_insights'].append("Total functions found: " + str(total_functions));
        }
        
        if total_classes > 0 {
            summary['top_insights'].append("Total classes found: " + str(total_classes));
        }
        
        # Generate recommendations
        if scan_results['scanned_files'] == 0 {
            summary['recommendations'].append("No scannable files found - check directory path");
        } elif total_functions == 0 and scan_results['scanned_files'] > 0 {
            summary['recommendations'].append("Consider adding more functions to improve code organization");
        }
        
        return summary;
    }

    # Clear caches
    def clear_caches() {
        self.scan_cache = {};
        self.file_index = {};
        print("Caches cleared");
    }

    # Get performance stats
    def get_performance_stats() -> dict {
        return self.performance_stats;
    }
}
