import com.code_intelligence.jazzer.api.FuzzedDataProvider;
import com.example.BranchingPuzzle;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

/**
 * Fuzzer harness for OSS-Fuzz to test the BranchingPuzzle vulnerability.
 * This class provides the entry point for Jazzer to fuzz the branching puzzle.
 */
public class TestFuzzer {
    
    private static final BranchingPuzzle puzzle = new BranchingPuzzle();
    
    /**
     * Main fuzzer entry point for OSS-Fuzz.
     * This method will be called by Jazzer with fuzzed input data.
     * 
     * @param input Raw byte array of fuzzed input data
     */
    public static void fuzzerTestOneInput(byte[] input) {
        try {
            // Feed the fuzzed input to our vulnerable puzzle
            String result = puzzle.processPuzzleInput(input);
            System.out.println("[PUZZLE RESULT] " + result);
            
            // The fuzzer should eventually discover an input sequence that:
            // 1. Has magic bytes "FUZZ" at the start
            // 2. Has correct XOR checksum
            // 3. Has valid length and command extraction
            // 4. Contains "jazze" as the command
            // 
            // When this happens, the puzzle will attempt to execute "jazze"
            // as an OS command, triggering Jazzer's sanitizer detection
            
        } catch (Exception e) {
            // Let security-related exceptions propagate to trigger detection
            // but catch other exceptions to keep fuzzing stable
            if (e.getMessage() != null && 
                (e.getMessage().contains("jazze") || 
                 e.getMessage().contains("Runtime.exec") ||
                 e.getMessage().contains("ProcessBuilder"))) {
                // This indicates we've hit the vulnerability
                System.out.println("[VULNERABILITY DETECTED] " + e.getMessage());
                throw new RuntimeException("OS Command Injection detected: " + e.getMessage(), e);
            }
            // Ignore other exceptions to continue fuzzing
        }
    }
}