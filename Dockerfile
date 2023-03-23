FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV COMMIT=8a308fc18d36b4ffa89fa4d0ab50c324382c0477
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN cd op-node && \
    make op-node


FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV COMMIT=11f0554a4313ea0e0aaddef194058b057aadce5c
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
