#!/bin/bash
echo "Verifying CKAD Candidate Tasks..."
SCORE=0
TOTAL=13

# 1. Verify Secret and Pod
if kubectl get secret db-credentials > /dev/null 2>&1 && \
   kubectl get pod env-secret-pod > /dev/null 2>&1 && \
   kubectl get pod env-secret-pod -o jsonpath='{.spec.containers[*].env[?(@.valueFrom.secretKeyRef.name=="db-credentials")]}' | grep -q "db-credentials"; then
    echo "Task1: Verify Secret and Pod -->> Passed"
    ((SCORE++))
else
    echo "Task1: Verify Secret and Pod -->> Failed"
fi

# 2. Verify Ingress routing
if kubectl get ingress internal-api-ingress > /dev/null 2>&1 && \
   kubectl get ingress internal-api-ingress -o jsonpath='{.spec.rules[*].host}' | grep -q "internal-company.local" && \
   kubectl get ingress internal-api-ingress -o jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}' | grep -q "internal-api-service"; then
    echo "Task2: Verify Ingress Configuration -->> Passed"
    ((SCORE++))
else
    echo "Task2: Verify Ingress Configuration -->> Failed"
fi

# 3. Verify RBAC Configuration
if kubectl get sa dev-sa -n meta > /dev/null 2>&1 && \
   kubectl get role dev-deploy-role -n meta > /dev/null 2>&1 && \
   kubectl get rolebinding dev-deploy-rb -n meta > /dev/null 2>&1 && \
   kubectl get deployment dev-deployment -n meta -o jsonpath='{.spec.template.spec.serviceAccountName}' | grep -q "dev-sa"; then
    echo "Task3: Verify RBAC Configuration -->> Passed"
    ((SCORE++))
else
    echo "Task3: Verify RBAC Configuration -->> Failed"
fi

# 4. Verify Liveness Probe
if kubectl get pod health > /dev/null 2>&1 && \
   kubectl get pod health -o jsonpath='{.spec.containers[*].livenessProbe.httpGet.path}' | grep -q "/healthz"; then
    echo "Task4: Verify Liveness Probe -->> Passed"
    ((SCORE++))
else
    echo "Task4: Verify Liveness Probe -->> Failed"
fi

# 5. Verify Resource Requests
if kubectl get deploy resource-deploy -n ns-quota1 > /dev/null 2>&1 && \
   kubectl get deploy resource-deploy -n ns-quota1 -o jsonpath='{.spec.template.spec.containers[*].resources.requests.memory}' | grep -q "250Mi"; then
    echo "Task5: Verify Resource Requests -->> Passed"
    ((SCORE++))
else
    echo "Task5: Verify Resource Requests -->> Failed"
fi

# 6. Verify Security Context
if kubectl get deploy security-deploy -n ckad0021 > /dev/null 2>&1; then
   RUN_AS_USER=$(kubectl get deploy security-deploy -n ckad0021 -o jsonpath='{.spec.template.spec.containers[*].securityContext.runAsUser}')
   ALLOW_PRIV=$(kubectl get deploy security-deploy -n ckad0021 -o jsonpath='{.spec.template.spec.containers[*].securityContext.allowPrivilegeEscalation}')
   if [[ "$RUN_AS_USER" == *"1000"* ]] && [[ "$ALLOW_PRIV" == *"false"* ]]; then
       echo "Task6: Verify Security Context -->> Passed"
       ((SCORE++))
   else
       echo "Task6: Verify Security Context -->> Failed"
   fi
else
    echo "Task6: Verify Security Context -->> Failed"
fi

# 7. Verify Container Export and Run
if [ -f "/data1/ubuntu-apache-3.0.tar" ] && { sudo docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "apache-pod1" || sudo podman ps -a --format '{{.Names}}' 2>/dev/null | grep -q "apache-pod1"; }; then
    echo "Task7: Verify Container Export and Run -->> Passed"
    ((SCORE++))
else
    echo "Task7: Verify Container Export and Run -->> Failed"
fi

# 8. Verify Deployment Scaling and Service 
if kubectl get deploy kdpd002024-deployment -n kdpd002024 >/dev/null 2>&1 && \
   kubectl get svc srv-kdpd002024 -n kdpd002024 >/dev/null 2>&1; then
    
    REPLICAS=$(kubectl get deploy kdpd002024-deployment -n kdpd002024 -o jsonpath='{.spec.replicas}')
    LABEL=$(kubectl get deploy kdpd002024-deployment -n kdpd002024 -o jsonpath='{.spec.template.metadata.labels.role}')
    SVC_PORT=$(kubectl get svc srv-kdpd002024 -n kdpd002024 -o jsonpath='{.spec.ports.port}')
    SVC_TYPE=$(kubectl get svc srv-kdpd002024 -n kdpd002024 -o jsonpath='{.spec.type}')
    
    if [ "$REPLICAS" == "5" ] && [ "$LABEL" == "webfrontend" ] && [ "$SVC_PORT" == "8000" ] && [ "$SVC_TYPE" == "NodePort" ]; then
        echo "Task8: Verify Deployment Scaling and Service -->> Passed"
        ((SCORE++))
    else
        echo "Task8: Verify Deployment Scaling and Service -->> Failed"
    fi
else
    echo "Task8: Verify Deployment Scaling and Service -->> Failed"
fi

# 9. Verify Custom Nginx Deployment Configuration
if kubectl get deploy mydeploy -n kdp0024 >/dev/null 2>&1; then
    REPLICAS=$(kubectl get deploy mydeploy -n kdp0024 -o jsonpath='{.spec.replicas}')
    IMAGE=$(kubectl get deploy mydeploy -n kdp0024 -o jsonpath='{.spec.template.spec.containers.image}')
    ENV_VAR=$(kubectl get deploy mydeploy -n kdp0024 -o jsonpath='{.spec.template.spec.containers.env[?(@.name=="NGINX_Port")].value}')
    PORT=$(kubectl get deploy mydeploy -n kdp0024 -o jsonpath='{.spec.template.spec.containers.ports[?(@.containerPort==8080)].containerPort}')
    if [ "$REPLICAS" == "3" ] && [ "$IMAGE" == "nginx:1.24.0" ] && [ "$ENV_VAR" == "8080" ] && [ "$PORT" == "8080" ]; then
        echo "Task9: Verify mydeploy Configuration -->> Passed"
        ((SCORE++))
    else
        echo "Task9: Verify mydeploy Configuration -->> Failed"
    fi
else
    echo "Task9: Verify mydeploy Configuration -->> Failed"
fi

# 10. Verify Deployment Update Strategy
if kubectl get deploy web -n kdpd0023 >/dev/null 2>&1; then
    SURGE=$(kubectl get deploy web -n kdpd0023 -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')
    UNAVAIL=$(kubectl get deploy web -n kdpd0023 -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')
    # Tests that the strategy config updated since rolling back brings it to the older revision
    if [ "$SURGE" == "10%" ] && [ "$UNAVAIL" == "5%" ]; then
        echo "Task10: Verify web deployment strategy -->> Passed"
        ((SCORE++))
    else
        echo "Task10: Verify web deployment strategy -->> Failed"
    fi
else
    echo "Task10: Verify web deployment strategy -->> Failed"
fi

# 11. Verify CronJob Configuration
if kubectl get cronjob hellocron >/dev/null 2>&1; then
    SCHEDULE=$(kubectl get cronjob hellocron -o jsonpath='{.spec.schedule}')
    IMAGE=$(kubectl get cronjob hellocron -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers.image}')
    CMD=$(kubectl get cronjob hellocron -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers.command[*]}')
    DEADLINE=$(kubectl get cronjob hellocron -o jsonpath='{.spec.jobTemplate.spec.activeDeadlineSeconds}')
    if [ "$SCHEDULE" == "* * * * *" ] && [ "$IMAGE" == "busybox" ] && [[ "$CMD" == *"uname"* ]] && [ "$DEADLINE" == "28" ]; then
        echo "Task11: Verify CronJob hellocron -->> Passed"
        ((SCORE++))
    else
        echo "Task11: Verify CronJob hellocron -->> Failed"
    fi
else
    echo "Task11: Verify CronJob hellocron -->> Failed"
fi

# 12. Verify Broken Image is Fixed
if kubectl get deploy broken-image-deploy >/dev/null 2>&1; then
    READY_REPLICAS=$(kubectl get deploy broken-image-deploy -o jsonpath='{.status.readyReplicas}')
    if [ -n "$READY_REPLICAS" ] && [ "$READY_REPLICAS" -gt 0 ]; then
        echo "Task12: Verify broken image fix -->> Passed"
        ((SCORE++))
    else
        echo "Task12: Verify broken image fix -->> Failed"
    fi
else
    echo "Task12: Verify broken image fix -->> Failed"
fi

# 13. Verify Broken Liveness Probe Hunt and Fix Output
if [ -f "/var/data/broken.txt" ] && grep -q "failing-probe-pod/prod" /var/data/broken.txt; then
    READY=$(kubectl get pod failing-probe-pod -n prod -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    if [ "$READY" == "True" ]; then
        echo "Task13: Verify liveness probe fix and logs -->> Passed"
        ((SCORE++))
    else
        echo "Task13: Verify liveness probe fix and logs -->> Failed"
    fi
else
    echo "Task13: Verify liveness probe fix and logs -->> Failed"
fi

echo "======================================"
echo "Final Score: $SCORE / $TOTAL"
if [ "$SCORE" -eq "$TOTAL" ]; then
    echo "OVERALL RESULT: PASS"
else
    echo "OVERALL RESULT: FAIL"
fi
