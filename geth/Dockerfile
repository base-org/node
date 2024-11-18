FROM golang:1.22 AS op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.9.5
ENV COMMIT=5662448279e4fb16e073e00baeb6e458b12a59b2
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

FROM golang:1.22 AS geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV VERSION=v1.101411.1
ENV COMMIT=4539f2d3a77f14bdad362c24e3773dc6aad87d5b
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN go run build/ci.go install -static ./cmd/geth

FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y jq curl supervisor && \
    rm -rf /var/lib/apt/lists
RUN mkdir -p /var/log/supervisor

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=geth /app/build/bin/geth ./
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY geth/geth-entrypoint ./execution-entrypoint
COPY op-node-entrypoint .

CMD ["/usr/bin/supervisord"]
