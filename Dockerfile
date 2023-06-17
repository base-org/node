# syntax=docker/dockerfile:1-labs
FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism
ENV COMMIT=a541c8a859d9258ad410598655f189de69adae19
ENV CHECKSUM=a61e4e921c4ee83650eeff59d73aeae328b38728d54b2f4fd7f9387ef713b8a9
ADD --checksum=sha256:$CHECKSUM $REPO/archive/$COMMIT.tar.gz ./

RUN tar -xvf ./$COMMIT.tar.gz --strip-components=1 && \
    cd op-node && \
    make op-node

FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth
ENV COMMIT=b5fecf58ec77909c70bd15b96b32b593af0b38ff
ENV CHECKSUM=009ec82e9be9a8a444a4a587ded844c7336ed6c80c9029e9acd912578a477b0f
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
