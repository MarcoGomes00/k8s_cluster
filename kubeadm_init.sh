sudo wget https://docs.projectcalico.org/manifests/calico.yaml -P /root/

sudo tee /root/kubeadm-config.yaml<<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: 1.18.1               
controlPlaneEndpoint: "$1:6443"  
networking:
  podSubnet: 192.168.0.0/16
EOF

sudo kubeadm init --config=/root/kubeadm-config.yaml --upload-certs

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo cp /root/calico.yaml .
kubectl apply -f calico.yaml
sudo yum install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >>  ~/.bashrc

#create join.sh
token=`sudo kubeadm token create`
cert=`openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/ˆ.* //' | awk -F' ' '{print $2}'`

sudo tee /vagrant/join.sh<<EOF 
kubeadm join --token $token $1:6443 --discovery-token-ca-cert-hash sha256:$cert
EOF