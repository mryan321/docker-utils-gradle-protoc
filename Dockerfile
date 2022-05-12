FROM gradle:jdk8

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        jq \
        maven \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.google.com/go/go1.18.2.linux-amd64.tar.gz \
    && mkdir /go \
    && tar -C / -xzf go1.18.2.linux-amd64.tar.gz

ENV GOBIN="/go/bin"
ENV PATH="${PATH}:${GOBIN}"
RUN go version

RUN download_url=$(curl -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | \
      jq -r '.assets[] | select(.name | contains("'"$(uname | tr '[:upper:]' '[:lower:]')"'_amd64")) | .browser_download_url') \
    && curl -o /usr/local/bin/swagger -L'#' "$download_url" \
    && chmod +x /usr/local/bin/swagger

RUN git clone https://github.com/googleapis/googleapis.git \
    && git clone https://github.com/grpc-ecosystem/grpc-gateway.git

RUN curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.20.1/protoc-3.20.1-linux-x86_64.zip \
    && unzip protoc-3.20.1-linux-x86_64.zip -d protoc3 \
    && mv protoc3/bin/* /usr/local/bin/ \
    && mv protoc3/include/* /usr/local/include/ \
    && chown root /usr/local/bin/protoc \
    && chown -R root /usr/local/include/google

RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
RUN go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
RUN go install github.com/markbates/pkger/cmd/pkger@latest