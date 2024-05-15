FROM golang:1.21 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.7.5
# for verification:
ENV COMMIT=e87e5ef2b96893eb8b446da420f7ba7f3e3c5985

RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

FROM golang:1.21 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV VERSION=v1.101315.0
# for verification:
ENV COMMIT=ef178f2555afc821a0a522db1f24f06ddab80f3c

# avoid depth=1, so the geth build can read tags
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN go run build/ci.go install -static ./cmd/geth

FROM golang:1.21

RUN apt-get update && \
    apt-get install -y jq curl supervisor && \
    rm -rf /var/lib/apt/lists
RUN mkdir -p /var/log/supervisor

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=geth /app/build/bin/geth ./
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY geth-entrypoint .
COPY op-node-entrypoint .
COPY sepolia ./sepolia
COPY mainnet ./mainnet

CMD ["/usr/bin/supervisord"]
