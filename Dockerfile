# syntax=docker/dockerfile:1-labs
FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism
ENV COMMIT=09d23ee8995b7c318a4469a49276f9453535c6a9
ENV CHECKSUM=593338d48967154182d07920fcaf51d18e8c6adb64485356b059e1a1f82fe941
ADD --checksum=sha256:$CHECKSUM $REPO/archive/$COMMIT.tar.gz ./

RUN tar -xvf ./$COMMIT.tar.gz --strip-components=1 && \
    cd op-node && \
    make op-node

FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth
ENV COMMIT=a84992a3b7c33f038ccc69e761bafeefcd605fd3
ENV CHECKSUM=8d97c1292c67afb08c124fc1f6586f92ec127464e04749b80eed709de145df17
ADD --checksum=sha256:$CHECKSUM $REPO/archive/$COMMIT.tar.gz ./

RUN tar -xvf ./$COMMIT.tar.gz --strip-components=1 && \
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
