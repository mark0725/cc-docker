IMAGE="registry.server.gingkoo/ai/claude-code:latest"
EXTRA_ARGS=""

PROJECT_ID=`pwd|sed  's/\//_/g'`

# 解析选项
while [ $# -gt 0 ]; do
    case "$1" in
        --java8)
            IMAGE="registry.server.gingkoo/ai/claude-code:java8"
            shift
            ;;
        --java)
            IMAGE="registry.server.gingkoo/ai/claude-code:java17"
            shift
            ;;
        *)
            EXTRA_ARGS="$EXTRA_ARGS $1"
            shift
            ;;
    esac
done

echo "==> 使用镜像: ${IMAGE}"
echo "==> 宿主机 UID/GID: $(id -u)/$(id -g)"

docker run -it --rm \
    --user 0 \
    -e "HOST_UID=$(id -u)" \
    -e "HOST_GID=$(id -g)" \
    -e "HOME=/home/node" \
    -v node_home:/home/node \
    -v "`pwd`:/home/node/workspace/${PROJECT_ID}" \
    -v "${HOME}/.claude:/home/node/.claude" \
    -w "/workspace/${PROJECT_ID}" \
  "${IMAGE}" claude --dangerously-skip-permissions --allowedTools "Edit,Write,Bash" ${EXTRA_ARGS}
