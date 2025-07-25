#!/usr/bin/env python3
"""
OSS-Fuzz Build Script Patcher

This class patches OSS-Fuzz project build.sh scripts to insert jar execution
after git clone commands but before the actual build process.
"""

import os
import re
import shutil
from pathlib import Path
from typing import List, Tuple, Optional


class BuildScriptPatcher:
    """
    Patches OSS-Fuzz build.sh scripts to insert jar execution after git clone.
    """
    
    def __init__(self, jar_path: str, jar_args: str = ""):
        """
        Initialize the patcher.
        
        Args:
            jar_path: Path to the jar file to execute
            jar_args: Additional arguments to pass to the jar
        """
        self.jar_path = jar_path
        self.jar_args = jar_args
        
    def _find_git_clone_patterns(self, content: str) -> List[Tuple[int, str]]:
        """
        Find git clone patterns in the build script content.
        
        Returns:
            List of tuples (line_number, line_content) where git clone occurs
        """
        patterns = [
            r'git\s+clone\s+',
            r'git\s+-C\s+\S+\s+pull\s+\|\|\s+git\s+clone\s+',
            r'git\s+.*clone.*'
        ]
        
        lines = content.split('\n')
        matches = []
        
        for i, line in enumerate(lines):
            for pattern in patterns:
                if re.search(pattern, line):
                    matches.append((i, line))
                    break
                    
        return matches
    
    def _generate_jar_command(self, project_dir: str = None) -> str:
        """
        Generate the jar execution command to insert.
        
        Args:
            project_dir: The project directory if known
            
        Returns:
            The command string to insert
        """
        cmd_parts = [
            "# Execute instrumentation jar after git clone",
            f"echo 'Running instrumentation jar: {self.jar_path}'",
            f"java -jar {self.jar_path}"
        ]
        
        if self.jar_args:
            cmd_parts[-1] += f" {self.jar_args}"
            
        if project_dir:
            cmd_parts[-1] += f" {project_dir}"
            
        cmd_parts.append("")  # Add blank line after
        
        return '\n'.join(cmd_parts)
    
    def _extract_project_dir_from_clone(self, clone_line: str) -> Optional[str]:
        """
        Extract the project directory from a git clone command.
        
        Args:
            clone_line: The line containing git clone
            
        Returns:
            The project directory name if found
        """
        # Pattern: git clone <url> <dir>
        match = re.search(r'git\s+clone\s+\S+\s+(\S+)', clone_line)
        if match:
            return match.group(1)
            
        # Pattern: git -C <dir> pull || git clone <url> <dir>
        match = re.search(r'git\s+-C\s+(\S+)\s+pull\s+\|\|\s+git\s+clone\s+\S+\s+(\S+)', clone_line)
        if match:
            return match.group(1)  # Use the directory from -C
            
        return None
    
    def patch_build_script(self, script_path: str, backup: bool = True) -> bool:
        """
        Patch a single build.sh script.
        
        Args:
            script_path: Path to the build.sh script
            backup: Whether to create a backup before patching
            
        Returns:
            True if patching was successful, False otherwise
        """
        script_path = Path(script_path)
        
        if not script_path.exists():
            print(f"Script not found: {script_path}")
            return False
            
        # Create backup if requested
        if backup:
            backup_path = script_path.with_suffix('.sh.backup')
            shutil.copy2(script_path, backup_path)
            print(f"Created backup: {backup_path}")
        
        # Read the script content
        try:
            with open(script_path, 'r') as f:
                content = f.read()
        except Exception as e:
            print(f"Error reading {script_path}: {e}")
            return False
        
        # Find git clone patterns
        clone_matches = self._find_git_clone_patterns(content)
        
        if not clone_matches:
            print(f"No git clone commands found in {script_path}")
            return False
        
        # Split content into lines for modification
        lines = content.split('\n')
        
        # Process matches in reverse order to maintain line numbers
        for line_num, clone_line in reversed(clone_matches):
            project_dir = self._extract_project_dir_from_clone(clone_line)
            jar_command = self._generate_jar_command(project_dir)
            
            # Insert the jar command after the git clone line
            insert_pos = line_num + 1
            jar_lines = jar_command.split('\n')
            
            for i, jar_line in enumerate(jar_lines):
                lines.insert(insert_pos + i, jar_line)
            
            print(f"Inserted jar execution after line {line_num + 1}: {clone_line.strip()}")
        
        # Write the modified content back
        try:
            with open(script_path, 'w') as f:
                f.write('\n'.join(lines))
            print(f"Successfully patched: {script_path}")
            return True
        except Exception as e:
            print(f"Error writing {script_path}: {e}")
            return False
    
    def patch_project(self, project_name: str, oss_fuzz_root: str = ".", backup: bool = True) -> bool:
        """
        Patch a specific OSS-Fuzz project's build script.
        
        Args:
            project_name: Name of the project to patch
            oss_fuzz_root: Root directory of OSS-Fuzz repository
            backup: Whether to create backups
            
        Returns:
            True if successful, False otherwise
        """
        build_script = Path(oss_fuzz_root) / "projects" / project_name / "build.sh"
        return self.patch_build_script(str(build_script), backup)
    
    def patch_all_projects(self, oss_fuzz_root: str = ".", backup: bool = True) -> dict:
        """
        Patch all OSS-Fuzz project build scripts that contain git clone.
        
        Args:
            oss_fuzz_root: Root directory of OSS-Fuzz repository
            backup: Whether to create backups
            
        Returns:
            Dictionary with project names as keys and success status as values
        """
        projects_dir = Path(oss_fuzz_root) / "projects"
        results = {}
        
        if not projects_dir.exists():
            print(f"Projects directory not found: {projects_dir}")
            return results
        
        # Find all build.sh scripts
        build_scripts = list(projects_dir.glob("*/build.sh"))
        
        print(f"Found {len(build_scripts)} build scripts")
        
        for build_script in build_scripts:
            project_name = build_script.parent.name
            print(f"\nProcessing project: {project_name}")
            
            success = self.patch_build_script(str(build_script), backup)
            results[project_name] = success
        
        # Print summary
        successful = sum(1 for success in results.values() if success)
        total = len(results)
        print(f"\nPatching complete: {successful}/{total} projects patched successfully")
        
        return results


def main():
    """Example usage of the BuildScriptPatcher."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Patch OSS-Fuzz build scripts with jar execution")
    parser.add_argument("jar_path", help="Path to the jar file to execute")
    parser.add_argument("--jar-args", default="", help="Additional arguments for the jar")
    parser.add_argument("--project", help="Specific project to patch (if not specified, patches all)")
    parser.add_argument("--oss-fuzz-root", default=".", help="Root directory of OSS-Fuzz repo")
    parser.add_argument("--no-backup", action="store_true", help="Skip creating backups")
    
    args = parser.parse_args()
    
    patcher = BuildScriptPatcher(args.jar_path, args.jar_args)
    
    if args.project:
        success = patcher.patch_project(args.project, args.oss_fuzz_root, not args.no_backup)
        if success:
            print(f"Successfully patched project: {args.project}")
        else:
            print(f"Failed to patch project: {args.project}")
    else:
        results = patcher.patch_all_projects(args.oss_fuzz_root, not args.no_backup)
        failed_projects = [name for name, success in results.items() if not success]
        if failed_projects:
            print(f"Failed to patch projects: {', '.join(failed_projects)}")


if __name__ == "__main__":
    main()