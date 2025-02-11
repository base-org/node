FROM golang:1.22 AS op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.10.2
ENV COMMIT=8bf7ff60f34a7c5082cec5c56bed1f76cc1893ad
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

# Install 'just'
RUN curl -sSfL 'https://just.systems/install.sh' | bash -s -- --to /usr/local/bin

RUN cd op-node && \
    make VERSION=$VERSION op-node

FROM mcr.microsoft.com/dotnet/sdk:9.0-noble AS build

ARG BUILD_CONFIG=release
ARG TARGETARCH

WORKDIR /app

ENV REPO=https://github.com/NethermindEth/nethermind.git
ENV VERSION=1.30.3
ENV COMMIT=87c863793b2302209187432b6afe5d7d84918bab
RUN git clone $REPO --branch $VERSION --single-branch . && \
    git switch -c $VERSION 
RUN bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN TARGETARCH=${TARGETARCH#linux/} && \
    arch=$([ "$TARGETARCH" = "amd64" ] && echo "x64" || echo "$TARGETARCH") && \
    echo "Using architecture: $arch" && \
    dotnet publish src/Nethermind/Nethermind.Runner -c $BUILD_CONFIG -a $arch -o /publish --sc false

FROM mcr.microsoft.com/dotnet/aspnet:9.0-noble

RUN apt-get update && \
    apt-get install -y jq curl supervisor && \
    rm -rf /var/lib/apt/lists

RUN mkdir -p /var/log/supervisor

WORKDIR /app

COPY --from=build /publish ./
COPY --from=op /app/op-node/bin/op-node ./
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nethermind/nethermind-entrypoint ./execution-entrypoint
COPY op-node-entrypoint .

CMD ["/usr/bin/supervisord"]
