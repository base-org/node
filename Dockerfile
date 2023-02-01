FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV COMMIT=3c3e1a88b234a68bcd59be0c123d9f3cc152a91e
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN cd op-node && \
    make op-node


FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV COMMIT=0678a130d7908b64aea596320099d30463119169
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN go run build/ci.go install -static ./cmd/geth


FROM golang:1.19

RUN apt-get update && \
    apt-get install -y jq curl

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=geth /app/build/bin/geth ./
COPY . .
