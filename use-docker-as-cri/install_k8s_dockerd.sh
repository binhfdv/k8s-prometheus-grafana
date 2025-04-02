# network clear-up and cluster reset
sudo sysctl net.ipv4.conf.all.forwarding=1
sudo iptables -P FORWARD ACCEPT
sudo swapoff -a
sudo ufw disable

sudo ip link delete flannel.1 
sudo ip link delete cni0 
sudo rm $HOME/.kube/config
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo systemctl enable docker

if ! command -v kubeadm &> /dev/null; then
    echo "kubeadm is not installed on the system"
    apt list -a kubeadm
else
    # Run kubeadm reset with error handling
    if sudo kubeadm reset -f; then
        echo "kubeadm reset completed successfully"
    else
        echo "Failed to reset kubeadm"
    fi
fi

sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*


# k8s installation
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet=1.30.5-1.1 kubectl=1.30.5-1.1 kubeadm=1.30.5-1.1
sudo apt-mark hold kubelet kubectl kubeadm

# 
echo "Initializing k8s cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/cri-dockerd.sock

sleep 5
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml