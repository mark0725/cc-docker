ARG BASE_IMAGE_REGISTRY=ghcr.io/mark0725/agent-go-docker

FROM ${BASE_IMAGE_REGISTRY}:latest

ARG HTTP_PROXY
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTP_PROXY}
ENV PROXY_URL=${HTTP_PROXY}

ENV GOPROXY=https://proxy.golang.com.cn,direct
ARG GO_VERSION=1.26.1
ENV GOPATH="/home/node/go"
RUN GOARCH=${TARGETARCH:-$(dpkg --print-architecture)} && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz \
    | tar -C /usr/local -xzf - && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go && \
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt && \
    printf '%s\n' \
        'export GOPATH="/home/node/go"' \
        'export PATH="/home/node/go/bin:/usr/local/go/bin:/usr/local/bin:$PATH"' \
        > /etc/profile.d/go-path.sh && \
    chmod +x /etc/profile.d/go-path.sh

ENV PATH="${GOPATH}/bin:/usr/local/go/bin:/usr/local/bin:${PATH}"

# Unset http proxy
ENV HTTP_PROXY=
ENV HTTPS_PROXY=
ENV PROXY_URL=
