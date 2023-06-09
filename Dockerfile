FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism
ENV COMMIT=09d23ee8995b7c318a4469a49276f9453535c6a9
ADD $REPO/archive/$COMMIT.tar.gz ./

RUN tar -xvf ./$COMMIT.tar.gz --strip-components=1 && \
    cd op-node && \
    make op-node

FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth
ENV COMMIT=a84992a3b7c33f038ccc69e761bafeefcd605fd3
ADD $REPO/archive/$COMMIT.tar.gz ./

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
