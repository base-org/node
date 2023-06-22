# syntax=docker/dockerfile:1-labs
FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism
ENV VERSION=v1.1.0
ENV CHECKSUM=f84bbf1b069dc2f2570c3f6989ae464cd3ede12faf7f4f6796e97380de7f8923
ADD --checksum=sha256:$CHECKSUM $REPO/archive/op-node/$VERSION.tar.gz ./

RUN tar -xvf ./$VERSION.tar.gz --strip-components=1 && \
    cd op-node && \
    make op-node

FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth
ENV VERSION=v1.101106.0-rc.3
ENV CHECKSUM=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
ADD --checksum=sha256:$CHECKSUM $REPO/archive/$VERSION.tar.gz ./

RUN tar -xvf ./$VERSION.tar.gz --strip-components=1 && \
    go run build/ci.go install -static ./cmd/geth

FROM golang:1.19

RUN apt-get update && \
    apt-get install -y jq curl && \
    rm -rf /var/lib/apt/lists

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=geth /app/build/bin/geth ./
COPY geth-entrypoint .
COPY op-node-entrypoint .
COPY goerli ./goerli
