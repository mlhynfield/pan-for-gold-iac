#!/bin/bash

curl -sfL https://get.k3s.io | sh -s - \
--write-kubeconfig-mode 0644 \
--tls-san "`curl -s https://checkip.amazonaws.com`" \
--secrets-encryption true

until kubectl get pods -A | grep 'Running'; do
sleep 5
done

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/core-install.yaml

kubectl config set-context --current --namespace argocd

until kubectl get pods -n argocd | grep 'Running'; do
sleep 5
done

sleep 15

curl -sSL -o argocd-linux-arm64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-arm64
sudo install -m 555 argocd-linux-arm64 /usr/local/bin/argocd
rm argocd-linux-arm64

sleep 15

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

argocd --core repo add ${var.repo_url}

argocd --core app create ${var.name} \
--repo "${var.repo_url}.git" \
--path manifest --dest-namespace default \
--dest-server https://kubernetes.default.svc --directory-recurse \
--sync-policy automated

until kubectl get deploy -n default | grep '${var.name}'; do
sleep 5
done

kubectl config set-context --current --namespace default

kubectl -n default expose deploy ${var.name} \
--port 80 --target-port 3000

kubectl -n default create ingress ${var.name} \
--rule="/=${var.name}:80" \
--annotation kubernetes.io/ingress.class=traefik