# OSS-Fuzz Integration for Fuzzer Test Project

This directory contains the OSS-Fuzz integration files for the fuzzer test project.

## Files

- **project.yaml**: OSS-Fuzz project configuration
- **Dockerfile**: Docker environment for building the fuzzer
- **build.sh**: Build script that compiles the project and creates the fuzzer
- **TestFuzzer.java**: Fuzzer harness that feeds data to the BranchingPuzzle (located in this directory)

## How it Works

The fuzzer harness (`TestFuzzer.java`) takes random input from OSS-Fuzz and feeds it to the `BranchingPuzzle.processPuzzleInput()` method. The puzzle has a 4-layer validation system:

1. **Magic bytes**: Must start with "FUZZ"
2. **Checksum**: XOR checksum must equal 0x37
3. **Command extraction**: Valid length field and command string
4. **Command execution**: Triggers OS command injection when command="jazzer"

## Target Vulnerability

When the fuzzer discovers the correct input sequence, it will trigger the OS command injection vulnerability in `BranchingPuzzle.executeCommand()`, which calls `Runtime.exec(command)` when the command is "jazzer". This should be detected by Jazzer's sanitizer.

## Testing Locally

To test this integration locally with OSS-Fuzz:

1. Clone OSS-Fuzz repository
2. Copy this directory to `oss-fuzz/projects/fuzzer-test/`
3. Update the `main_repo` URL in `project.yaml`
4. Run: `python infra/helper.py build_image fuzzer-test`
5. Run: `python infra/helper.py build_fuzzers fuzzer-test`
6. Run: `python infra/helper.py run_fuzzer fuzzer-test TestFuzzer`