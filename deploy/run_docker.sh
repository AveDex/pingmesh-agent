# 停止容器
docker stop pingmesh-agent

# 移除容器
docker rm pingmesh-agent

docker run -d \
    --name pingmesh-agent \
    --restart=always \
    -p 9115:9115  \
    -v /etc/hosts:/etc/hosts:ro \
    ave-registry.cn-hongkong.cr.aliyuncs.com/infra/pingmesh-agent:v1.0.5-amd64
