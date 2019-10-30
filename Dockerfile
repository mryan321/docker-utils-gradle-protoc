FROM gradle:jdk8

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        golang-go \
        jq \
        maven \
    && rm -rf /var/lib/apt/lists/*

ENV GOPATH="/go"
ENV GOBIN="/go/bin"
ENV PATH="${PATH}:${GOBIN}"

RUN download_url=$(curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | \
      jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url') \
    && curl -o /usr/local/bin/swagger -L'#' "$download_url" \
    && chmod +x /usr/local/bin/swagger

RUN git clone https://github.com/googleapis/googleapis.git \
    && git clone https://github.com/grpc-ecosystem/grpc-gateway.git

RUN curl -OL https://github.com/google/protobuf/releases/download/v3.9.1/protoc-3.9.1-linux-x86_64.zip \
    && unzip protoc-3.9.1-linux-x86_64.zip -d protoc3 \
    && mv protoc3/bin/* /usr/local/bin/ \
    && mv protoc3/include/* /usr/local/include/ \
    && chown root /usr/local/bin/protoc \
    && chown -R root /usr/local/include/google

RUN go get -u github.com/golang/protobuf/protoc-gen-go \
    && go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway \
    && go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger

ADD https://github.com/golang/dep/releases/download/v0.5.3/dep-linux-amd64 /usr/bin/dep
RUN chmod +x /usr/bin/dep