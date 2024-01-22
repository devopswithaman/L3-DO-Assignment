# Add Helm repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Deploy Prometheus
kubectl get namespace prometheus >/dev/null 2>&1
if [ $? -ne 0 ]; then
    kubectl create namespace prometheus
    helm install stable prometheus-community/kube-prometheus-stack -n prometheus
else
    echo 'Namespace prometheus already exists.'
fi

# Patch Services
kubectl patch svc stable-kube-prometheus-sta-prometheus -n prometheus --type=json -p='[{"op":"replace","path":"/spec/type","value":"LoadBalancer"}]'
kubectl patch svc stable-grafana -n prometheus --type=json -p='[{"op":"replace","path":"/spec/type","value":"LoadBalancer"}]'

# Get Service URLs
prometheus=$(kubectl get svc stable-kube-prometheus-sta-prometheus -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" | tr -d '\n')
grafana=$(kubectl get svc stable-grafana -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" | tr -d '\n')
