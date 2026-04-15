# agent-go-docker

用于启动 Claude Code 容器环境的 Docker 镜像与本地启动脚本。

## 构建说明

### 本地构建基础镜像

```bash
docker build -t agent-go-docker:latest -f Dockerfile .
```

### 构建语言变体镜像

```bash
docker build -t agent-go-docker:java8  -f Dockerfile.java8 .
docker build -t agent-go-docker:java17 -f Dockerfile.java17 .
docker build -t agent-go-docker:java21 -f Dockerfile.java21 .
docker build -t agent-go-docker:java25 -f Dockerfile.java25 .
docker build -t agent-go-docker:go     -f Dockerfile.go .
docker build -t agent-go-docker:rust   -f Dockerfile.rust .
```

## 使用说明

### 1. 安装启动脚本

给脚本增加可执行权限，并安装命令链接：

```bash
chmod +x agent-go
./agent-go add
export PATH="$HOME/.local/bin:$PATH"
```

安装后可使用以下命令：

- `agent-cc`：启动 Claude Code 交互式 CLI
- `agent-cc-web`：启动 ttyd Web 终端 + tmux
- `agent-cc-tmux`：在 tmux 中启动 Claude Code

### 2. 基本启动

```bash
agent-cc
```

### 3. 选择镜像变体

```bash
agent-cc --java8
agent-cc --java
agent-cc --java21
agent-cc --java25
agent-cc --go
agent-cc --rust
```

其中 `--java` 等同于 `--java17`。

### 4. 传递 Claude 参数

```bash
agent-cc -p '帮我检查当前目录代码'
```

### 5. Web / tmux 模式

```bash
agent-cc-web
agent-cc-tmux
```

### 6. 常用环境变量

```bash
export AGENT_ID=default
export AGENT_IMAGE_REGISTRY=ghcr.io/mark0725/agent-go-docker
export CLAUDE_HOME=$HOME/.claude
export AGENTS_HOME=$HOME/.agents
export AGENTS_HUB=$HOME/.agents-hub
```

### 7. 直接使用 Docker 运行

```bash
docker run -it --rm --network=host \
  --user 0 \
  -e "HOST_UID=$(id -u)" \
  -e "HOST_GID=$(id -g)" \
  -e "HOME=/home/node" \
  -e "AGENT_ID=default" \
  -v node_home:/home/node \
  -v "$PWD:/workspace/$(pwd | sed 's#/#_#g')" \
  -v "$HOME/.claude:/home/node/.claude" \
  -v "$HOME/.agents:/home/node/.agents" \
  -v "$HOME/.agents-hub:/home/node/.agents-hub" \
  -w "/workspace/$(pwd | sed 's#/#_#g')" \
  ghcr.io/mark0725/agent-go-docker:latest \
  claude
```
