# cc-docker

Claude Code 的 Docker 镜像，支持多架构（amd64/arm64），提供多种语言环境变体。

## 镜像变体

| 变体 | Dockerfile | 说明 |
|------|-----------|------|
| `latest` | `Dockerfile` | Node.js 24 + Python 3 + Go + Claude Code |
| `java8` | `Dockerfile.java8` | 上述 + Java 8 (Temurin) + Maven |
| `java17` | `Dockerfile.java17` | 上述 + Java 17 (Temurin) + Maven |

所有镜像基于 `node:24-slim`，包含 git、curl、vim、neovim、ripgrep、fd-find、jq 等常用开发工具。

## 快速开始

使用 `cc` 脚本一键启动 Claude Code：

```bash
# 默认使用 latest 镜像
./cc

# 使用 Java 8 环境
./cc --java8

# 使用 Java 17 环境
./cc --java

# 传递额外参数给 claude
./cc --dangerously-skip-permissions
```

`cc` 脚本会自动：
- 映射宿主机 UID/GID，容器内文件权限与宿主机一致
- 挂载当前目录到容器内 workspace
- 挂载 `~/.claude` 配置目录，保持会话持久化
- 挂载 `node_home` 卷，持久化容器内 home 目录

## 手动运行

```bash
docker run -it --rm \
  --user 0 \
  -e "HOST_UID=$(id -u)" \
  -e "HOST_GID=$(id -g)" \
  -e "HOME=/home/node" \
  -v node_home:/home/node \
  -v "$(pwd):/home/node/workspace/$(pwd|sed 's/\//_/g')" \
  -v "${HOME}/.claude:/home/node/.claude" \
  ghcr.io/mark0725/cc-docker:latest
```

## 本地构建

```bash
# 单架构构建
docker build -t claude-code:latest .

# 多架构构建并推送（需要 buildx）
bash build.sh
```

## CI/CD

推送到 `main` 分支或打 `v*` tag 时，GitHub Actions 自动构建并推送多架构镜像到 GHCR。

- `main` 分支推送 → 构建并打 `latest`/`java8`/`java17` tag
- `v1.0.0` tag → 额外打 `1.0.0-latest`/`1.0.0-java8`/`1.0.0-java17` tag
- PR → 仅构建验证，不推送镜像

## 环境变量

| 变量 | 必需 | 说明 |
|------|------|------|
| `ANTHROPIC_API_KEY` | 是 | Anthropic API 密钥 |
| `HOST_UID` / `HOST_GID` | 否 | 宿主机用户 UID/GID，用于文件权限映射 |

## License

MIT
