# 1) Using the helper script (from the root of oss‑fuzz)
mkdir -p ../out/static_corpus
#python /scripts/gen_payload.py out/static_corpus/seed1

echo 'hello, world!' > out/static_corpus/seed2.txt

sleep 10

python infra/helper.py run_fuzzer \
  --engine libfuzzer \
  --sanitizer address \
  --architecture x86_64 \
  --corpus-dir out/static_corpus \
  slf4j-api \
  LoggingFuzzer \
  -- \
  -runs=10000000000000000000
