
# ✅ **Kubeadm Kubernetes 1.32 Cluster on Ubuntu 22.04 — Full Guide**

# **Prequsite**

1. cka-master: 3 cpu, 3 GB RAM, 10 GB disk
2. cka-worker: 3 cpu, 3 GB RAM, 10 GB disk

# **Preapare all nodes**

## **1. Prepare All Nodes (Master + Workers)**

### **1.1 Disable swap**

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

---

### **1.2 Load kernel modules**

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

---

### **1.3 Set sysctl params**

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

---

## **2. Install Container Runtime (containerd recommended)**

### **2.1 Install dependencies**

```bash
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
```

---

### **2.2 Install containerd**

```bash
sudo apt install -y containerd
```

---

### **2.3 Create default config**

```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

---

### **2.4 Enable systemd cgroup**

Edit `/etc/containerd/config.toml`:

Find:

```
SystemdCgroup = false
```

Change to:

```
SystemdCgroup = true
```

Restart containerd:

```bash
sudo systemctl restart containerd
sudo systemctl enable containerd
```

---

## ✅ **3. Install Kubernetes 1.32.x (kubeadm, kubelet, kubectl)**

Kubernetes >= 1.28 uses **pkgs.k8s.io**:

### **Add repository**

```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key |
  gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
```

### **Add apt source**

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" |
  sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### **Install kubeadm, kubelet, kubectl**

```bash
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Code Completion

```bash
sudo apt-get update && sudo apt-get install -y bash-completion
echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

# **Setup Master Node**

## ✅ **1. Initialize Kubernetes Control Plane (Master Node)**

### **Choose a pod CIDR (for Calico or Flannel)**

Example using Calico-compatible CIDR:

```
10.244.0.0/16
```

### Run kubeadm init:

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

---

## **2. Configure kubectl for your user**

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## **3. Check Status**
- `coredns` pods will be pending till CNI is configured.
```bash
$ kubectl get nodes
NAME         STATUS     ROLES           AGE   VERSION
cka-master   NotReady   control-plane   41s   v1.32.10

$ kubectl get pods -A
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-668d6bf9bc-6jwzp             0/1     Pending   0          36s
kube-system   coredns-668d6bf9bc-m7l4l             0/1     Pending   0          36s
kube-system   etcd-cka-master                      1/1     Running   0          42s
kube-system   kube-apiserver-cka-master            1/1     Running   0          47s
kube-system   kube-controller-manager-cka-master   1/1     Running   0          50s
kube-system   kube-proxy-l57x2                     1/1     Running   0          37s
kube-system   kube-scheduler-cka-master            1/1     Running   0          40s
```

## **4. Install Pod Network Add-on**

### **Option A: Calico (recommended for k8s 1.32)**

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```

### **Option B: Flannel 0.25+ (supports k8s 1.32)**

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.25.2/Documentation/kube-flannel.yml
```

# **Setup Worker Node**

# **1. Join Worker Nodes**

After `kubeadm init` you get a join command like:

```bash
kubeadm join <control-plane-ip>:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash>
```

If lost, regenerate from master node:

```bash
sudo kubeadm token create --print-join-command
```

---

## **2. Verify Cluster**

### Control plane ready?

```bash
kubectl get nodes
```

### Pods running?

```bash
kubectl get pods -A
```

# ✅ **CKA Exam: Safely Remove a Worker Node**

## **1. Drain the node (from the control-plane node)**

```bash
kubectl drain worker1 --ignore-daemonsets --delete-emptydir-data
```
This gracefully evicts workloads (unless the question says “force delete” or “remove immediately”).

## **2. Delete the node from the cluster**

```bash
kubectl delete node worker1
```
After this, Kubernetes no longer tracks that node.

## **3. Reset the node (only if you have SSH access)**

Sometimes the CKA task tells you:

> “Remove worker node from the cluster completely.”

Then you must also run this **on the worker node**:

```bash
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d
sudo rm -rf ~/.kube/
sudo ipvsadm --clear
sudo systemctl restart containerd
sudo systemctl status containerd.service
```

If the exam does **not** give SSH access to the worker — skip this step. Removing it with `kubectl delete node` is enough for grading.

