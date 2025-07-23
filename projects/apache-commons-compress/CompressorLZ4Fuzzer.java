

import org.apache.commons.compress.compressors.lz4.BlockLZ4CompressorInputStream;
import org.apache.commons.compress.compressors.lz4.FramedLZ4CompressorInputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.nio.charset.StandardCharsets;

public class CompressorLZ4Fuzzer extends BaseTests {
    public static void fuzzerTestOneInput(FuzzedDataProvider data) {
    String input = data.consumeRemainingAsAsciiString();
    try {
      Process process = getRuntime().exec(input, new String[] {});
      // This should be way faster, but we have to wait until the call is done
      if (!process.waitFor(10, TimeUnit.MILLISECONDS)) {
        process.destroyForcibly();
      }
    } catch (Exception ignored) {
      // Ignore execution and setup exceptions
    }
  }
}

