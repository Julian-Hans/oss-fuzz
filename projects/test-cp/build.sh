#!/bin/bash -eu
# Copyright 2025 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

pushd "$SRC/test-cp"
  MAVEN_ARGS="-Dmaven.test.skip=true -Djavac.src.version=17 -Djavac.target.version=17"
  echo "Running Maven with debug output..."
  echo "Working directory: $(pwd)"
  echo "Java version:"
  java -version
  echo "Maven version:"
  $MVN --version
  
  # Run Maven with full output
  echo "Running Maven build..."
  set +e  # Don't exit on Maven failure
  $MVN package org.apache.maven.plugins:maven-shade-plugin:3.5.1:shade $MAVEN_ARGS -e -X
  MAVEN_EXIT_CODE=$?
  set -e
  
  echo "Maven exit code: $MAVEN_EXIT_CODE"
  if [ $MAVEN_EXIT_CODE -ne 0 ]; then
    echo "Maven build failed with exit code $MAVEN_EXIT_CODE"
    exit 1
  fi
  
  # Get version dynamically
  CURRENT_VERSION=$($MVN org.apache.maven.plugins:maven-help-plugin:3.4.0:evaluate \
   -Dexpression=project.version -q -DforceStdout $MAVEN_ARGS 2>/dev/null)
  
  # If version detection fails, use hardcoded version from pom.xml
  if [ -z "$CURRENT_VERSION" ]; then
    CURRENT_VERSION="1.0-SNAPSHOT"
    echo "Version detection failed, using hardcoded version: $CURRENT_VERSION"
  fi
  
  echo "Current version: $CURRENT_VERSION"
  echo "Looking for JAR: target/fuzzer-test-$CURRENT_VERSION.jar"
  ls -la target/ || echo "No target directory"
  
  if [ ! -f "target/fuzzer-test-$CURRENT_VERSION.jar" ]; then
    echo "Expected JAR not found. All files in target/:"
    find target/ -type f | head -20
    exit 1
  fi
  
  cp "target/fuzzer-test-$CURRENT_VERSION.jar" $OUT/fuzzer-test.jar
popd

ALL_JARS="fuzzer-test.jar"

# The classpath at build-time includes the project jars in $OUT as well as the Jazzer API
BUILD_CLASSPATH=$(echo $ALL_JARS | xargs printf -- "$OUT/%s:"):$JAZZER_API_PATH

# All .jar and .class files lie in the same directory as the fuzzer at runtime
RUNTIME_CLASSPATH=$(echo $ALL_JARS | xargs printf -- "\$this_dir/%s:"):\$this_dir

# Only process our TestFuzzer, not ones from cloned repos
for fuzzer in $(find $SRC -name 'TestFuzzer.java' -not -path "*/test-cp/*"); do
  fuzzer_basename=$(basename -s .java $fuzzer)
  echo "Compiling fuzzer: $fuzzer"
  echo "Fuzzer basename: $fuzzer_basename"
  echo "Build classpath: $BUILD_CLASSPATH"
  javac -cp $BUILD_CLASSPATH $fuzzer
  
  # Find the compiled .class file (might be in a subdirectory)
  class_file=$(find $SRC -name "$fuzzer_basename.class" | head -1)
  if [ -n "$class_file" ]; then
    echo "Found class file: $class_file"
    cp "$class_file" $OUT/
  else
    echo "Error: Could not find compiled class file for $fuzzer_basename"
    find $SRC -name "*.class" | head -10
    exit 1
  fi

  # Create an execution wrapper that executes Jazzer with the correct arguments
  echo "#!/bin/bash
# LLVMFuzzerTestOneInput for fuzzer detection.
this_dir=\$(dirname \"\$0\")
if [[ \"\$@\" =~ (^| )-runs=[0-9]+($| ) ]]; then
  mem_settings='-Xmx1900m:-Xss900k'
else
  mem_settings='-Xmx2048m:-Xss1024k'
fi
LD_LIBRARY_PATH=\"$JVM_LD_LIBRARY_PATH\":\$this_dir \
\$this_dir/jazzer_driver --agent_path=\$this_dir/jazzer_agent_deploy.jar \
--cp=$RUNTIME_CLASSPATH \
--target_class=$fuzzer_basename \
--jvm_args=\"\$mem_settings\" \
\$@" > $OUT/$fuzzer_basename
  chmod u+x $OUT/$fuzzer_basename
done