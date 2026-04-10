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
ENV http_proxy=
ENV https_proxy=
ENV proxy_url=

COPY entrypoint.sh /entrypoint.sh

# 以 root 创建 node 用户的配置文件，运行时 entrypoint 会修正属主
WORKDIR /home/node
RUN git config --global init.defaultBranch main \
    && chown -R node:node /home/node

ENTRYPOINT ["/entrypoint.sh"]
CMD ["claude"]
