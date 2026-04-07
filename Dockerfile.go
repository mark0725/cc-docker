ARG BASE_IMAGE_REGISTRY=ghcr.io/mark0725/agent-go-docker

FROM ${BASE_IMAGE_REGISTRY}:latest

ARG HTTP_PROXY=

# Set http proxy
RUN if [ -n "$HTTP_PROXY" ]; then \
        echo "Configuring proxy..."; \
        export http_proxy=$HTTP_PROXY; \
        export https_proxy=$HTTP_PROXY; \
        export proxy_url=$HTTP_PROXY; \
    fi

ENV GOPROXY=https://proxy.golang.com.cn,direct
ARG GO_VERSION=1.26.1
RUN GOARCH=${TARGETARCH:-$(dpkg --print-architecture)} && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz \
    | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

ENV GOPATH="/home/node/go"
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

# Unset http proxy
RUN if [ -n "$HTTP_PROXY" ]; then \
        unset http_proxy; \
        unset https_proxy; \
        unset proxy_url; \
    fi
