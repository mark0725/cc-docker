FROM node:24-slim

ARG USER_UID=1000
ARG USER_GID=1000
ARG TARGETARCH

ARG HTTP_PROXY
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTP_PROXY}
ENV PROXY_URL=${HTTP_PROXY}

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# ===== 基础工具 =====
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    tmux \
    vim \
    neovim \
    ripgrep \
    fd-find \
    jq \
    tree \
    htop \
    build-essential \
    openssh-client \
    ca-certificates \
    sudo \
    locales \
    && rm -rf /var/lib/apt/lists/*


ARG TTYD_VERSION="1.7.7"

RUN ARCH=$(uname -m) && \
    case ${ARCH} in \
        x86_64)  TTYD_ARCH="x86_64" ;; \
        aarch64) TTYD_ARCH="aarch64"  ;; \
        *)       echo "Unsupported architecture: ${ARCH}"; exit 1 ;; \
    esac && \
    TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" && \
    wget -O /usr/local/bin/ttyd ${TTYD_URL} && \
    chmod +x /usr/local/bin/ttyd

ENV PATH="/usr/local/bin:${PATH}"

# 设置 locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ===== Python =====
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# ===== Docker CLI (可选，用于 DinD 场景) =====
# RUN curl -fsSL https://get.docker.com | sh

# ===== 安装 Claude Code =====
RUN npm install -g @anthropic-ai/claude-code

# ===== 安装 Codex =====
RUN npm i -g @openai/codex

# ===== UID 映射: gosu + entrypoint =====
RUN ARCH=${TARGETARCH:-$(dpkg --print-architecture)} && \
    curl -fsSL --http1.1 "https://github.com/tianon/gosu/releases/download/1.17/gosu-${ARCH}" -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu

USER node

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

USER root

# Unset http proxy
ENV HTTP_PROXY=
ENV HTTPS_PROXY=
ENV PROXY_URL=

COPY entrypoint.sh /entrypoint.sh

# 以 root 创建 node 用户的配置文件，运行时 entrypoint 会修正属主
WORKDIR /home/node
RUN git config --global init.defaultBranch main \
    && chown -R node:node /home/node

EXPOSE 7681

ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude"]
