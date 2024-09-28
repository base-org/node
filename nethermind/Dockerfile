FROM golang:1.21 AS op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.9.1
ENV COMMIT=4797ddb70e05d4952685bad53e608cb5606284e6
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
    git switch -c branch-$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN cd op-node && \
    make VERSION=$VERSION op-node

FROM mcr.microsoft.com/dotnet/sdk:8.0-noble AS build

ARG BUILD_CONFIG=release
ARG TARGETARCH

WORKDIR /app

ENV REPO=https://github.com/NethermindEth/nethermind.git
ENV VERSION=1.29.0
ENV COMMIT=e324dae2a92e23f2cd351d81e9e46554591b2cef
RUN git clone $REPO --branch release/$VERSION --single-branch . && \
    git switch -c release/$VERSION && \
    bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN arch=$([ "$TARGETARCH" = "amd64" ] && echo "x64" || echo "$TARGETARCH") && \
    dotnet publish src/Nethermind/Nethermind.Runner -c $BUILD_CONFIG -a $arch -o /publish --sc false 


FROM mcr.microsoft.com/dotnet/aspnet:8.0-noble

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