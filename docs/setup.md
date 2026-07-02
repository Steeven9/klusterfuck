# Setup

Install some utilities on both nodes

```bash
echo " cgroup_memory=1 cgroup_enable=memory" >> /boot/firmware/cmdline.txt

sudo apt-get update && sudo apt-get install -y nfs-common
```

Install and set up k3s on node 1 (control plane)

```bash
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
```

Install and set up k3s on node 2

```bash
sudo ufw allow 10250/tcp
sudo ufw allow 10256/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw allow 30000:32767/udp

export K3S_TOKEN="replace-with-a-strong-secret"
export NODE01_IP="192.168.178.67"

curl -sfL https://get.k3s.io | \
  K3S_URL="https://${NODE01_IP}:6443" \
  K3S_TOKEN="${K3S_TOKEN}" sh -

# check, should be both ready
kubectl get nodes
```

On your local machine

```bash
brew install kubectl fluxcd/tap/flux

export NODE01_IP="192.168.178.67"
mkdir -p ~/.kube
scp ${NODE01_IP}:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i "s/127.0.0.1/${NODE01_IP}/" ~/.kube/config
chmod 600 ~/.kube/config

# confirm remote access works
kubectl get nodes  
```

This part needs a GitHub access token with Contents (r/w) and Administration (r/w) scopes on the repo

```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
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
```
