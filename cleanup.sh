3. Cleanup Script (cleanup.sh)
This script now destroys the resources introduced for tasks 9 through 13.
#!/bin/bash
echo "Cleaning up CKAD resources..."

# Cleanup Tasks 1-4
kubectl delete secret db-credentials --ignore-not-found
kubectl delete pod env-secret-pod --ignore-not-found
kubectl delete ingress internal-api-ingress --ignore-not-found
kubectl delete service internal-api-service --ignore-not-found
kubectl delete deployment internal-api --ignore-not-found
kubectl delete namespace meta --ignore-not-found
kubectl delete pod health --ignore-not-found

# Cleanup Tasks 5-6
kubectl delete namespace ns-quota1 --ignore-not-found
kubectl delete namespace ckad0021 --ignore-not-found

# Cleanup Task 7
sudo docker rm -f apache-pod1 >/dev/null 2>&1 || true
sudo podman rm -f apache-pod1 >/dev/null 2>&1 || true
sudo rm -rf /datadir /data1

# Cleanup Tasks 8-10 
kubectl delete namespace kdpd002024 kdp0024 kdpd0023 --ignore-not-found

# Cleanup Task 11
kubectl delete cronjob hellocron --ignore-not-found

# Cleanup Task 12
kubectl delete deployment broken-image-deploy --ignore-not-found

# Cleanup Task 13
kubectl delete namespace qa lab prod dev --ignore-not-found
sudo rm -rf /var/data

echo "Cleanup complete."
