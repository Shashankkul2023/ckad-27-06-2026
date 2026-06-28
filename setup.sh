#!/bin/bash
echo "Setting up resources for CKAD scenarios..."

# Task 1: Secrets and Environment Variables
# Create a Pod with hardcoded environment variables that the candidate must replace with secrets
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hardcoded-env-pod
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: DB_USERNAME
      value: testusername
    - name: DB_PASSWORD
      value: zyfsfsf
    - name: DB_NAME
      value: applicationdb
EOF

# Task 2: Ingress 
kubectl create deployment internal-api --image=nginx -n default
kubectl expose deployment internal-api --name=internal-api-service --port=3000 --target-port=80 -n default

# Task 3: RBAC 
kubectl create namespace meta
kubectl create deployment dev-deployment --image=nginx -n meta

# Task 4: Liveness Probe 
kubectl run health --image=nginx --port=80 -n default

# Task 5: Resource Requests
kubectl create namespace ns-quota1
kubectl create quota mem-quota --hard=limits.memory=500Mi -n ns-quota1
kubectl create deployment resource-deploy --image=nginx -n ns-quota1

# Task 6: Security Context
kubectl create namespace ckad0021
kubectl create deployment security-deploy --image=nginx -n ckad0021

# Task 7: Container build and export
sudo mkdir -p /datadir /data1
cat <<'EOF' | sudo tee /datadir/Dockerfile > /dev/null
FROM ubuntu:14.04
MAINTAINER Anish Rana
ENV TZ=Asia/Dubai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y apache2
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
EOF

# Task 8: Deployment Scaling and NodePort Service
kubectl create namespace kdpd002024
kubectl create deployment kdpd002024-deployment --image=nginx -n kdpd002024

# Task 9: New Nginx Deployment (GitHub Q1)
kubectl create namespace kdp0024

# Task 10: Rolling Updates & Surge (GitHub Q2)
kubectl create namespace kdpd0023
kubectl create deployment web --image=nginx:1.24.0 -n kdpd0023

# Task 11: CronJob creation (GitHub Q3)
sudo mkdir -p /var/data

# Task 12: Broken Image Deployment (GitHub Q4)
kubectl create deployment broken-image-deploy --image=nginx:1.999.999 -n default

# Task 13: Liveness Probe Hunt & Fix (GitHub Q5)
for ns in qa lab prod dev; do kubectl create ns $ns; done
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: failing-probe-pod
  namespace: prod
spec:
  containers:
  - name: nginx
    image: nginx
    livenessProbe:
      exec:
        command: ["cat", "/nonexistent"]
      initialDelaySeconds: 5
      periodSeconds: 5
EOF

echo "Setup complete. The cluster is ready for the candidate."
