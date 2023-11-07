FROM golang:1.20 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.3.1
# for verification:
ENV COMMIT=74ff044a9869e440aa270b65681182950576004e

RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make op-node

FROM golang:1.20 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV VERSION=v1.101304.1
# for verification:
ENV COMMIT=ed8e9f54ed0a5069e77ea34895ff12a9ac4ca17f

# avoid depth=1, so the geth build can read tags
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN go run build/ci.go install -static ./cmd/geth

FROM golang:1.20

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
COPY goerli ./goerli
COPY sepolia ./sepolia
COPY mainnet ./mainnet

CMD ["/usr/bin/supervisord"]
