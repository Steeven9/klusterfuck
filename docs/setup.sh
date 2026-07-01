# both nodes

echo " cgroup_memory=1 cgroup_enable=memory" >> /boot/firmware/cmdline.txt

sudo apt-get update && sudo apt-get install -y nfs-common

# node 1

sudo ufw allow 6443
sudo ufw allow 10250 #TODO necessary?

export K3S_TOKEN="replace-with-a-strong-secret"
export NODE01_IP="192.168.178.67"

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --disable=local-storage \
  --tls-san=${NODE01_IP} \
  --write-kubeconfig-mode=644" \
  K3S_TOKEN="${K3S_TOKEN}" sh -

# check, should be ready
sudo kubectl get nodes

# node 2

sudo ufw allow 10250

export K3S_TOKEN="replace-with-a-strong-secret"
export NODE01_IP="192.168.178.67"

curl -sfL https://get.k3s.io | \
  K3S_URL="https://${NODE01_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" sh -

# check on node 1, should be both
sudo kubectl get nodes


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

# in the repo
mkdir -p cluster/infrastructure/sources
mkdir -p cluster/infrastructure/storage/nfs-provisioner
mkdir -p cluster/apps
