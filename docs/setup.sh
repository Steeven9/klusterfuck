# both nodes

echo " cgroup_memory=1 cgroup_enable=memory" >> /boot/firmware/cmdline.txt

sudo apt-get update && sudo apt-get install -y nfs-common

# node 1

sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10257/tcp
sudo ufw allow 10259/tcp

export K3S_TOKEN="replace-with-a-strong-secret"
export NODE01_IP="192.168.178.67"

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable=local-storage \
  --tls-san=${NODE01_IP} \
  --write-kubeconfig-mode=644" \
  K3S_TOKEN="${K3S_TOKEN}" sh -

# check, should be ready
kubectl get nodes

# node 2

sudo ufw allow 10250/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw allow 30000:32767/udp

export K3S_TOKEN="replace-with-a-strong-secret"
export NODE01_IP="192.168.178.67"

curl -sfL https://get.k3s.io | \
  K3S_URL="https://${NODE01_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" sh -

kubectl get nodes

# on devbox

brew install kubectl fluxcd/tap/flux

export NODE01_IP="192.168.178.67"
mkdir -p ~/.kube
scp ${NODE01_IP}:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i "s/127.0.0.1/${NODE01_IP}/" ~/.kube/config
chmod 600 ~/.kube/config

kubectl get nodes   # confirm remote access works

export GITHUB_TOKEN="ghp_xxxxxxxxxxxx" # needs contents and administration r/w  
export GITHUB_USER="steeven9"
export REPO_NAME="klusterfuck"

flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=${REPO_NAME} \
  --branch=main \
  --path=cluster \
  --personal \
  --private

flux check
kubectl -n flux-system get pods
