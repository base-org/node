FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV COMMIT=759c0b297c3dfa05370c27b9380c7bffb67b12d2
RUN git init && \
    git remote add origin $REPO && \
    git fetch --depth=1 origin $COMMIT && \
    git reset --hard FETCH_HEAD

RUN cd op-node && \
    make op-node


FROM golang:1.19 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV COMMIT=c407b2a217b78d13d33f86873bbf38af6e73523e
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
