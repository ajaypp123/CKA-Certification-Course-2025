# microk8s start

```sh
microk8s start
```

# Enable metalb
```
 microk8s enable metallb:192.168.1.245-192.168.1.250
```

# Enable ingress
```
microk8s enable ingress
```

## Add lb ingress service
kubectl apply -f ingress-svc.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress
  namespace: ingress
spec:
  selector:
    name: nginx-ingress-microk8s
  type: LoadBalancer
  # loadBalancerIP is optional. MetalLB will automatically allocate an IP 
  # from its pool if not specified. You can also specify one manually.
  loadBalancerIP: 192.168.1.247
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 443
```

## Add /etc/hosts entry
```
192.168.1.247   example.com
```

# Gateway API

- kind cluster
```yaml
# kind create cluster --name=gateway-api --config=kind.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1@sha256:050072256b9a903bd914c0b2866828150cb229cea0efe5892e2b644d5dd3b34f
    extraPortMappings:
      - containerPort: 31080  # Port inside the KIND container
        hostPort: 31080       # Port on your local machine
      - containerPort: 31433  # Port inside the KIND container
        hostPort: 31433       # Port on your local machine
```


- install gateway
```sh
# Add crds
->$ kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.1.0" | kubectl apply -f -

# check crds
->$ kubectl api-resources | grep gateway
gatewayclasses    gc          gateway.networking.k8s.io/v1          false GatewayClass
gateways          gtw         gateway.networking.k8s.io/v1          true  Gateway
grpcroutes                    gateway.networking.k8s.io/v1          true  GRPCRoute
httproutes                    gateway.networking.k8s.io/v1          true  HTTPRoute
referencegrants   refgrant    gateway.networking.k8s.io/v1beta1     true  ReferenceGrant

# Install nginx gateway controller
->$ helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --create-namespace -n ngf-gatewayapi-ns \
  --set nginx.service.type=NodePort \
  --set-json 'nginx.service.nodePorts=[{"port":31080,"listenerPort":80}]'
```
