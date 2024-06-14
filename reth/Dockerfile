FROM golang:1.21 AS op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.7.6
# for verification:
ENV COMMIT=4a487b8920daa9dc4b496d691d5f283f9bb659b1

RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

FROM rust:1.78 AS reth

ARG FEATURES=jemalloc,asm-keccak,optimism

WORKDIR /app

RUN apt-get update && apt-get -y upgrade && apt-get install -y git libclang-dev pkg-config curl build-essential

ENV REPO=https://github.com/paradigmxyz/reth.git
ENV COMMIT=e5111f03396f661bdff69d04047d0c076bad75f3

RUN git clone $REPO . && git checkout $COMMIT
RUN cargo build --bin op-reth --locked --features $FEATURES --profile maxperf

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y jq curl supervisor && \
    rm -rf /var/lib/apt/lists
RUN mkdir -p /var/log/supervisor

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=reth /app/target/maxperf/op-reth ./
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./reth/reth-entrypoint ./execution-entrypoint
COPY op-node-entrypoint .

CMD ["/usr/bin/supervisord"]
