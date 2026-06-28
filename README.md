**Instructions:** Please complete the following tasks. Once you are finished, the `verify.sh` script will be run to evaluate your cluster and grade your work.

---

### Task 1: Secrets and Environment Variables
1. Create a Secret named `db-credentials` containing any key-value pairs you choose.
2. Create a Pod named `env-secret-pod` running an `nginx` image.
3. Configure the pod to load the `db-credentials` secret as environment variables.

### Task 2: Ingress Configuration
1. An existing deployment `internal-api` and service `internal-api-service` (on port 3000) exist in the `default` namespace. 
2. Create an Ingress named `internal-api-ingress`.
3. Route the host `internal-company.local` on the path `/home` to the `internal-api-service` backend.

### Task 3: RBAC Configuration
1. In the `meta` namespace, create a ServiceAccount named `dev-sa`.
2. Create a Role named `dev-deploy-role` that allows getting, listing, and watching deployments in the `meta` namespace.
3. Create a RoleBinding named `dev-deploy-rb` linking `dev-deploy-role` to the `dev-sa` ServiceAccount.
4. Update the existing deployment `dev-deployment` in the `meta` namespace to use the `dev-sa` ServiceAccount.

### Task 4: Liveness Probe
1. An existing pod named `health` is running in the `default` namespace.
2. Edit the pod to add an HTTP GET liveness probe on port `80` targeting the path `/healthz`.

### Task 5: Resource Requests
1. In the `ns-quota1` namespace, there is a hard memory quota of 500Mi.
2. Update the existing deployment `resource-deploy` in this namespace so that its containers request exactly half of the available namespace memory (250Mi).

### Task 6: Security Context
1. Modify the existing deployment `security-deploy` in the `ckad0021` namespace.
2. Configure the Pod template's Security Context to run as user `1000`.
3. Set `allowPrivilegeEscalation` to `false` for the containers.

### Task 7: Container Build and Run
1. Navigate to `/datadir` and locate the existing `Dockerfile`.
2. Build a container image from this Dockerfile and tag it as `ubuntu-apache:3.0`.
3. Run a container named `apache-pod1` in the background using this newly built image.
4. Export the image into a tar archive located at `/data1/ubuntu-apache-3.0.tar`.

### Task 8: Deployment Scaling and Services
1. In the `kdpd002024` namespace, scale the `kdpd002024-deployment` to 5 replicas.
2. Add the label `role: webfrontend` to the pod template in the deployment.
3. Expose the deployment by creating a NodePort service named `srv-kdpd002024` that listens on port `8000`.

### Task 9: New NGINX Deployment
1. Create a new deployment named `mydeploy` in the `kdp0024` namespace [1, 2].
2. Configure it to run with 3 replicas and use the `nginx:1.24.0` container image [2].
3. Set an environment variable of `NGINX_Port=8080` for the container and expose port `8080` [2].

### Task 10: Rolling Updates
1. Update the `web` deployment in the `kdpd0023` namespace with a `maxSurge` of `10%` and a `maxUnavailable` of `5%` [2, 3].
2. Perform a rolling update to change the image version from `nginx:1.24.0` to `nginx:1.24.1` [3].
3. Perform a rollback of the `web` deployment to its previous version [3].

### Task 11: CronJob Configuration
1. Create a manifest file at `/var/data/periodic.yaml` that defines a CronJob [3].
2. The CronJob and its container should both be named `hellocron` [4].
3. It should run a single `busybox` container executing the shell command `uname` [4].
4. Schedule it to run every minute and ensure it completes within 28 seconds (or is terminated by Kubernetes) [4]. Apply this configuration to the cluster.

### Task 12: Fix Broken Image
1. A deployment named `broken-image-deploy` in the `default` cluster is failing due to an incorrectly specified image [4, 5].
2. Locate the deployment and fix the image version so the pods successfully enter a `Ready` state [5].

### Task 13: Troubleshooting Liveness Probes
1. An application pod named `failing-probe-pod` is failing due to a broken liveness probe. It is located in one of the following namespaces: `qa`, `lab`, `prod`, or `dev` [5].
2. Identify the broken pod and write its name and namespace to `/var/data/broken.txt` in the format `<pod-name>/<namespace>` [5].
3. Copy the events describing the error into the file `/var/data/error.txt` using a `-o wide` output specifier [5].
4. Fix the liveness probe issue so the pod becomes healthy [5].

