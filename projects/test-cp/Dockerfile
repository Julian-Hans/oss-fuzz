# Copyright 2025 Google LLC
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

FROM gcr.io/oss-fuzz-base/base-builder-jvm

# Install Maven
RUN curl -L https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -o maven.tar.gz && \
    tar xzf maven.tar.gz -C $SRC && \
    rm maven.tar.gz

ENV MVN=$SRC/apache-maven-3.9.6/bin/mvn

# Clone the target repository (force fresh clone each time)
ARG CACHE_BUST=3
RUN git clone --depth 1 https://github.com/Julian-Hans/test-cp.git $SRC/test-cp

# Copy build script and fuzzer files
COPY build.sh $SRC/
COPY *.java $SRC/
WORKDIR $SRC/