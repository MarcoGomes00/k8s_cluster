yum update -y
#yum install -y epel-release
#yum install -y curl wget vim yum-utils ca-certificates libsodium gcc docker
yum clean all

# Install kubeadm, kubectl and kubelet
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

#Turn off swap
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

#Configure sysctl.
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

yum -y install epel-release vim git curl wget kubelet kubeadm kubectl --disableexcludes=kubernetes

#TODO
#yum install -y \
#  kubelet=#{KUBEADM_VERSION} \
#  kubeadm=#{KUBEADM_VERSION} \
#  kubectl=#{KUBEADM_VERSION}


# Install packages
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y && yum install -y containerd.io-1.2.13 docker-ce-19.03.8 docker-ce-cli-19.03.8

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

systemctl enable --now kubelet
systemctl start kubelet