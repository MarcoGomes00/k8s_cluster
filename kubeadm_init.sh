mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo cp /root/calico.yaml .
kubectl apply -f calico.yaml
sudo yum install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >>  ~/.bashrc