export KUBECONFIGBAK=$KUBECONFIG
export KUBECONFIG=~/.kube/pan-for-gold:~/.kube/config

kubectl config view --flatten > ~/.kube/merged
mv -f ~/.kube/merged ~/.kube/config
chmod 0600 ~/.kube/config

export KUBECONFIG=$KUBECONFIGBAK
unset KUBECONFIGBAK
