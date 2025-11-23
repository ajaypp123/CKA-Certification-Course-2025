
# **Day 44**
`https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/`

- headless service
- statefult set
- volumeclaimtemplate

## Headless service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app: nginx
```

## Statefulset

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx" # Provide headless service name
  replicas: 3
  minReadySeconds: 10
  template:
    metadata:
      labels:
        app: nginx
    spec:
      terminationGracePeriodSeconds: 10
      containers:
      - name: nginx
        image: registry.k8s.io/nginx-slim:0.24
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates: # Attach PersistaceVolumeClaim Template to assign volume to each state
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "microk8s-hostpath"
      resources:
        requests:
          storage: 1Gi

```

## DNS and PV
- DNS resolved at `<pod>.<hdl-svc>.<ns>.svc.cluster.local`, eg: `web-0.nginx.default.svc.cluster.local:80`

```sh
->$ kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        VOLUMEATTRIBUTESCLASS   AGE
www-web-0   Bound    pvc-de1be7bc-77e9-4e49-9cc2-9d92f45f8828   1Gi        RWO            microk8s-hostpath   <unset>                 6m55s
www-web-1   Bound    pvc-8bb0f774-ea38-4cc7-8787-6f35901b67ef   1Gi        RWO            microk8s-hostpath   <unset>                 6m27s
www-web-2   Bound    pvc-1f56b6ed-f351-4766-bc1f-1067e43d6ed4   1Gi        RWO            microk8s-hostpath   <unset>                 6m8s

# DNS name
root@web-0:/# curl web-0.nginx.default.svc.cluster.local:80
Welcome to web-0.nginx.default.svc.cluster.local:80

root@web-0:/# curl web-1.nginx.default.svc.cluster.local:80
Welcome to web-1.nginx.default.svc.cluster.local:80

root@web-0:/# curl web-2.nginx.default.svc.cluster.local:80
Welcome to web-2.nginx.default.svc.cluster.local:80
```

# **Day 45**

- image pull secrets
- patch serviceaccount with imagepull secrets


## Create imagepull secrets
```sh
# create imagepull secrets
kubectl create secret docker-registry dockerhub-secrets --docker-username=ajaypp123 --docker-password=PASS --docker-email=ajaypp123@gmail.com --dry-run=client --docker-server=https://index.docker.io/v1/  -o yaml > dockerhub-screat.yaml
```

## Pass Secret to pod
- If serviceaccount is updated to patch secrets then this is not needed.
```yaml
sepc:
  imagePullSecrets:
  - name: dockerhub-secrets
```

## Path serviceaccount with imagepull secret
```yaml
apiVersion: v1
imagePullSecrets:
- name: dockerhub-secrets
kind: ServiceAccount
metadata:
  creationTimestamp: "2025-10-16T02:58:22Z"
  name: default
  namespace: default
```

# **Day 46**

## Why Pod Priority and Prreamption Exists

- When there is resource crunch then need to run critical pod by terminating low priority task.
- Avoid starrvation
- Run buiseness critical workload

## **PriorityClass**

### Summery
- clusterscope resource
- Higher value mean higher priority
- It has value upto `1 billion`, There are control plane pod having priority of `2 billion`
```sh
# Get control-plane priority class
->$ kubectl get pc
NAME                      VALUE        GLOBAL-DEFAULT   AGE   PREEMPTIONPOLICY
system-cluster-critical   2000000000   false            30d   PreemptLowerPriority
system-node-critical      2000001000   false            30d   PreemptLowerPriority

# Get Priority class name
->$ kubectl describe pod -n kube-system coredns-ccd8f67bc-7vsr8 | grep Priority
Priority:             2000000000
Priority Class Name:  system-cluster-critical
```

### Object

- **value**: Priority value upto `1 billan`
- **globalDefault**: If True, then this priority considered as default.
- **preemtionPolicy**: If set as Never, mean don't delete low priority class to run this priority class. default value `PreemptLowerPriority`.
- **description**: Details 

```yaml
# kubectl get pc system-cluster-critical -o yaml > pc.yaml
apiVersion: scheduling.k8s.io/v1
description: Default priority class
kind: PriorityClass
metadata:
  name: low-pc
preemptionPolicy: PreemptLowerPriority
value: 100
globalDefault: false
```

### Wokload
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  priorityClassName: high-pc
  containers:
    ...
```

# **Day 47**

## Network Policy

### What is Network Policy (netpol)
  NetworkPolicies are powerful resources used to control the traffic flow to and from pods at the IP address and port level, which corresponds to Layer 3 and Layer 4 of the OSI model.

- Control `pod level` traffic at IP and port level
- Define `ingress` (traffic comming in) and `egress` (traffic going out) rules.
- `workload isolation` and `security`
- Enforced by `CNI Plugin`.
- Applies to both internal and external traffic.

## Ingress and Egress traffic
- All incomming traffic is ingress and outgoing traffic is egress.

![Alt text](/images/47c.png)

- Here as shown above, by default all trafiic is allowed by all pod, even frontend pod can communicate with db directly.
- To allow proper communication need to apply traffic rules.

## Network Policy: Ingress and Egress Rules

### Rules Policy Seclectors Types
1. pod selector
```yaml
podSelector:
  matchLabels:
    role: backend
```

2. namespace Selector
```yaml
  namespaceSelector:
    matchLabels:
      app: app1
```

3. ip range selector
  This allows traffic from the `10.0.0.0/24` range except the specific IP `10.0.0.5`.
  For example, a backup service on `10.0.0.10` outside your cluster could connect to your database pod.
```yaml
  ipBlock:
    cidr: 10.0.0.0/24
    except:
      - 10.0.0.5/32
```

### Policy Example
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

### Policy Rules format

1. If we only provide Type without rules then it block all traffic
- For below it not have Egress rules so for given pod all outgoing traffic will be blocked.
```yaml
spec:
  podSelector:
    matchLabels:
      role: db
      app: myapp
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: backend
          app: myapp
    ports:
    - protocol: TCP
      port: 5678
```

2. AND and OR rules
```yaml
# And rule
  - ingress/egress
    - from/to
        # It applies to pod with label k8s-app from namespace with matching label (AND)
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns

# OR rule
  - ingress/egress
    - from/to
        # It applies to pod with label k8s-app with in same namespace (OR) any pod from namespace with matching label 
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
        - podSelector:
            matchLabels:
              k8s-app: kube-dns
```

3. allow all network traffic
```yaml
  ingress:
  - from:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 80
```

4. Access via service
- When we want to access pod via service then we need to allow coredns pod also to resolve dns name with service.
```yaml
# egress rule to sned allow pod to send traffic to coredns to resolve service name with ip
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

# **DNS Explained**

## DNS
- It is hierarchical and distributed naming system used to translate human-readeble domain name to machine usable IP address.
- It resolve IP address with domain name.

## Website Breakdown

- `www.kubernetes.io.`
```
.             Root                    - starting point of DNS
io            Top Level Domain (TLD)  - domain
kubernetes    Second Level Demain     - Registered under .io domain
www           Subdomain               - prefix to main domain
```

## DNS Lookup for `docs.kubernetes.io`

![Alt text](/images/DNS1a.png)


# **Day 48**

## DNS (CoreDNS) in Kubernetes

- CoreDNS is default DNS server in k8s run as deployment in kube-system.
- Create and Maintain records for pods
```sh
->$ kubectl get deployments.apps coredns -n kube-system
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
coredns   0/2     2            0           9h

->$ kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   9h
```

## FQDN
- This FQDN is enabled by CoreDNS optionally and kept as records.
```sh
# Resource    # FQDN      # Example
Service:    <svc>.<ns>.svc.cluster.local                  nginx-svc.default.svc.cluster.local
Pod         <pod-ip>.<svc>.<ns>.pod.cluster.local         10-220-2-10.nginx-svc.default.pod.cluster.local
StatefulSet <pod-name>.<hdl-svc>.<ns>.svc.cluster.local   pod-0.nginx-svc.default.svc.cluster.local
```

- Kubernetes DNS Records

| Resource Type    | Hostname / Record Name | Namespace | DNS Type | FQDN                                            | Resolves To                |
| ---------------- | ---------------------- | --------- | -------- | ----------------------------------------------- | -------------------------- |
| Service          | `nginx-svc`            | default   | A        | `nginx-svc.default.svc.cluster.local.`          | 10.96.48.49                |
| Service          | `app1-svc`             | app1-ns   | A        | `app1-svc.app1-ns.svc.cluster.local.`           | 10.96.161.240              |
| Pod              | `10-244-2-10`          | app1-ns   | A        | `10-244-2-10.app1-ns.pod.cluster.local.`        | 10.244.2.10                |
| StatefulSet Pod  | `pod-0.headless-svc`   | app1-ns   | A        | `pod-0.headless-svc.app1-ns.svc.cluster.local.` | Pod IP (stable)            |
| Headless Service | `headless-svc`         | app1-ns   | NONE     | `headless-svc.app1-ns.svc.cluster.local.`       | *No cluster IP* (uses SRV) |

---

## DNS Resolve conf
- Every pod resolve.conf configred with dns-system nameserver, so when we use nslookup it uses kube-dns to resolve name
- If we are using different namespce then we need to provide <svc>.<ns>
```sh
->$ kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   34m
```

- Resolve.conf
```sh
# Every pod resolve.conf configred with dns-system nameserver

->$ kubectl run debug-pod -it --image=nicolaka/netshoot --rm -- bash
debug-pod:~# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5
```

- nslookup
```sh
# nginx-svc resolve to nginx-svc.default.svc.cluster.local by resolv.conf where server address resolve to core-dns

# If in same namespace
debug-pod:~# nslookup nginx-svc
;; Got recursion not available from 10.96.0.10
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   nginx-svc.default.svc.cluster.local
Address: 10.96.76.214
;; Got recursion not available from 10.96.0.10

# If in different namespace
debug-pod:~# nslookup nginx-svc.default
;; Got recursion not available from 10.96.0.10
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   nginx-svc.default.svc.cluster.local
Address: 10.96.76.214
;; Got recursion not available from 10.96.0.10
```

## CoreDNS Config

```yaml
->$ kubectl get deployments.apps coredns -n kube-system -o yaml
      volumes:
      - configMap:
          defaultMode: 420
          items:
          - key: Corefile
            path: Corefile
          name: coredns
        name: config-volume
```

-  `kubectl get configmaps -n kube-system coredns`

| Directive / Plugin                                                        | Purpose                                                                                                                                                                                     |
| :------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `.:53`                                                                    | Declares the main server block. CoreDNS listens on all interfaces (`.`) on port 53, the standard DNS port.                                                                                  |
| `errors`                                                                  | Enables logging of DNS errors to stderr. Useful for debugging query failures or plugin issues.                                                                                              |
| `health { lameduck 5s }`                                                  | Exposes a `/health` endpoint for liveness probes. The `lameduck` option allows existing connections to drain for 5 seconds before shutdown.                                                 |
| `ready`                                                                   | Provides a `/ready` endpoint for readiness probes. Signals when CoreDNS is fully initialized and ready to serve DNS traffic.                                                                |
| `kubernetes cluster.local in-addr.arpa ip6.arpa`                          | Handles internal DNS for Services and Pods under the `cluster.local` domain. Also supports reverse lookups for IPv4 (`in-addr.arpa`) and IPv6 (`ip6.arpa`).                                 |
| `pods insecure`                                                           | Enables Pod IP-based lookups (e.g., `10-244-44-55.default.pod.cluster.local`) without requiring hostname annotations. May lead to stale or spoofed entries — not recommended in production. |
| `fallthrough in-addr.arpa ip6.arpa`                                       | Allows unresolved queries in the specified zones to pass to the next plugin (commonly `forward`). Used to avoid resolution dead-ends.                                                       |
| `ttl 30`                                                                  | Sets the DNS TTL to 30 seconds for records served by the `kubernetes` plugin.                                                                                                               |
| `prometheus :9153`                                                        | Exposes CoreDNS metrics on port 9153 in Prometheus format. Useful for observability and monitoring.                                                                                         |
| `forward . /etc/resolv.conf { max_concurrent 1000 }`                      | Forwards unresolved queries (typically external domains) to upstream resolvers defined in `/etc/resolv.conf`. Supports up to 1000 concurrent queries.                                       |
| `cache 30 { disable success cluster.local disable denial cluster.local }` | Caches external DNS responses for 30 seconds. Disables caching for both successful and failed queries under `cluster.local` to reflect dynamic cluster state.                               |
| `loop`                                                                    | Detects and prevents DNS resolution loops caused by misconfigured forwarders.                                                                                                               |
| `reload`                                                                  | Automatically reloads CoreDNS when the `Corefile` changes — no restart required.                                                                                                            |
| `loadbalance`                                                             | Randomizes the order of upstream nameservers to distribute DNS query load evenly.                                                                                                           |

---


## DNS Troubleshooting in Kubernetes

If DNS resolution is not working for services or pods within your Kubernetes cluster, use the following checklist to troubleshoot the issue:

### 1. **Verify CoreDNS is Running**

Ensure the CoreDNS pods are up and healthy.

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

Look for pods in the `Running` state and with `READY` status like `2/2`.

---

### 2. **Check CoreDNS Logs**

Inspect CoreDNS logs for errors or dropped queries.

```bash
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=100
```

Look for signs of loop errors, failures in the `forward` plugin, or failed resolutions.

---

### 3. **Test DNS from Within a Pod**

Use a test pod to perform DNS lookups using tools like `dig` or `nslookup`.

```bash
kubectl run dns-test --rm -it --image=nicolaka/netshoot -- bash
nslookup kubernetes.default
dig nginx-svc.default.svc.cluster.local
```

If these fail, it indicates DNS resolution is not working within the cluster.

---

### 4. **Verify `resolv.conf` Configuration**

Check the `/etc/resolv.conf` inside the Pod to see if it points to the correct cluster DNS (usually `10.96.0.10` in default kubeadm setups).

```bash
cat /etc/resolv.conf
```

Expected content (or similar):

```
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
```

---

### 5. **Check `nsswitch.conf`**

Ensure the lookup order includes `dns`. The file `/etc/nsswitch.conf` inside the container should have:

```
hosts: files dns
```

This ensures that the pod uses `/etc/hosts` first, then DNS.

---

### 6. **Inspect CoreDNS ConfigMap (`Corefile`)**

Ensure the CoreDNS configuration has the `kubernetes` plugin correctly set up, including the domain (e.g., `cluster.local`) and any necessary options like:

```txt
kubernetes cluster.local in-addr.arpa ip6.arpa {
  pods insecure
  fallthrough in-addr.arpa ip6.arpa
  ttl 30
}
```

Check with:

```bash
kubectl get configmap coredns -n kube-system -o yaml
```

---

### 7. **Check for Network Policy or Firewall Rules**

Ensure there are no NetworkPolicies or firewalls preventing UDP/TCP port 53 (DNS) access between pods and CoreDNS.

---

### 8. **Validate kubelet DNS Options**

Check the kubelet startup options (especially if running custom clusters) to verify correct DNS configuration flags are set, such as `--cluster-dns`.

---

### 9. **Look for Loop or Forwarding Errors**

If external DNS resolution is also failing (e.g., `nslookup google.com`), confirm that the `forward` plugin is correctly configured in the `Corefile`:

```txt
forward . /etc/resolv.conf
```

Ensure `/etc/resolv.conf` on the CoreDNS pods has valid upstream resolvers.

---

# **Day 49**

## Ingress
Ingress is k8s API object that defines HTTPS routing rules for external traffic.

### Ingress Benifit

- HTTP aware routing
  - path-based: myapp.com/app1, myapp.com/app2
  - host-based: app1.myapp.com, app2.myapp.com
  - TLS Termination
- Single load balancer service multiple apps
- Declerative routing rules

### Ingress Controller
- AWS Load Balancer Controller
- NGINX Ingress Controller
- HAProxy Ingress
- Traefix
- Contour
- Istio Ingress Gateway

## Ingress Working

![Real-World Ingress Flow](/images/49a.png)

- When Ingress Resources defined then Ingress controller update load balancer rules for traffic.

# **Day 50**

## Setup Ingress
- Follow Day 50 Installation step

### Ingress Class
- Annotation to set default ingress class `ingressclass.kubernetes.io/is-default-class: true`
- As we have multiple ingress controller ingress class help to decide which to use.
```sh
# List all ingress class
->$ kubectl get ingressclasses.networking.k8s.io
NAME     CONTROLLER             PARAMETERS   AGE
nginx    k8s.io/ingress-nginx   <none>       32m
public   k8s.io/ingress-nginx   <none>       32m

# describe ingress class
->$ kubectl describe ingressclasses.networking.k8s.io public
Name:         public
Labels:       <none>
Annotations:  ingressclass.kubernetes.io/is-default-class: true
Controller:   k8s.io/ingress-nginx
Events:       <none>
```

## Ingress Resources

### Path Based resource

**ingressClassName**
- Povide ingress class else default will be picked. 
- `kubectl get ingressclass`

**pathType**
- `Prefix`: It resolve `/path`, `/path/` to `/path`
- `Exact`: Only allow `/path` which path is defined.
- `Mixed`: prefers Exact
In some cases, multiple paths within an Ingress will match a request. In those cases precedence will be given first to the longest matching path. If two paths are still equally matched, precedence will be given to paths with an exact path type over prefix path type.


**Example**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

### Host Based rules

**Example**
- For given local machine we need to add host entry in /etc/hosts
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: public
  # Add hosts entry in node /etc/hosts to resolve names
  rules:
  - host: "iphone.example.com"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: iphone-svc
            port:
              number: 80
  - host: "desktop.example.com"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: desktop-svc
            port:
              number: 80

```

# **Day 52**

## Limitation of Ingress

- Ingress Resource is at namespace level, so multiple namespace cannot use same routing rules.
- It supports only HTTP and HTTPs, not support TCP, UDP, gRPC
- Dose not support rate limiting, rewrite requests, ssl redirect, traffic spliting
- Annotation are depend on ingressClass and can not be ported if switch to different class.

## Gateway API
Next Gen Ingress with multi protocol support, role separation and portable traffic management.

- Can be managed with multi-tenency
- TCP, UDP, gRPC supoorted
- Allow rate-limiting, ssl redirect, rewrite request
- Build with CRD

## Gateway API Resource Model and Role Alignment

**GatewayClass:**
- Type of loadbalancing implementation. It keep note of gateway controller.

**Gateway:**
- Atual load balancer instarnce, Listen to port.

**Route Object:**
- forward traffic from gateway to services.
- It can be Http, TCP, gRPC.

![Alt text](/images/52c.png)


## Gateway API Flow: Controller, GatewayClass, Gateway, and HTTPRoute

This diagram illustrates how the **Gateway API** components interact in a Kubernetes environment using the **NGINX Gateway Fabric** as an example. It follows the sequence from the controller detecting configuration changes to routing traffic to the correct backend.

![Alt text](/images/52b.png)

# **Day 53**

## Setup Gateway 
- Day 50 setup

## Objects

### GatewayClass
- Nginx controller setup by  default create `ngginx` gatewayclass.

**GatewayClass**
```sh
kubectl get gatewayclasses.gateway.networking.k8s.io
NAME    CONTROLLER                                   ACCEPTED   AGE
nginx   gateway.nginx.org/nginx-gateway-controller   True       23m
```

**GatewayClass Defination**
- It point to `NginxProxy` with controller name
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

**Status**
```sh
->$ kubectl describe gatewayclasses.gateway.networking.k8s.io
Name:         nginx
...
Spec:
  Controller Name:  gateway.nginx.org/nginx-gateway-controller
  Parameters Ref:
    Group:      gateway.nginx.org
    Kind:       NginxProxy
    Name:       ngf-proxy-config
    Namespace:  ngf-gatewayapi-ns
Status:
  Conditions:
    Last Transition Time:  2025-11-19T04:43:48Z
    Message:               GatewayClass is accepted
    Observed Generation:   1
    Reason:                Accepted
    Status:                True
    Type:                  Accepted
    Last Transition Time:  2025-11-19T04:43:48Z
    Message:               Gateway API CRD versions are supported
    Observed Generation:   1
    Reason:                SupportedVersion
    Status:                True
    Type:                  SupportedVersion
    Last Transition Time:  2025-11-19T04:43:48Z
    Message:               ParametersRef resource is resolved
    Observed Generation:   1
    Reason:                ResolvedRefs
    Status:                True
    Type:                  ResolvedRefs
```

### Create Gateway

**Summery**
- It allow traffic from host and forwoard to routes.

**AllowRoutes**
- Default value is configured to `Same`, which allow traffic from same namespace. Then routes object must be in same namespace. `All` can be configured to cross namespace traffic.
```yaml
      allowedRoutes:
        namespaces:
          from: All
```

**Example**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway
  namespace: ngf-gatewayapi-ns
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
```

**Status**

```
  Listeners:
    Attached Routes:  2
    Conditions:
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               Listener is accepted
      Observed Generation:   1
      Reason:                Accepted
      Status:                True
      Type:                  Accepted
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               Listener is programmed
      Observed Generation:   1
      Reason:                Programmed
      Status:                True
      Type:                  Programmed
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               All references are resolved
      Observed Generation:   1
      Reason:                ResolvedRefs
      Status:                True
      Type:                  ResolvedRefs
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               No conflicts
      Observed Generation:   1
      Reason:                NoConflicts
      Status:                False
      Type:                  Conflicted
```

### Create HttpRoutes

**Summery**
- gRPC, HTTP, HTTPS routes

**Example**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: iphone-route
  namespace: apps
spec:
  parentRefs:
  - name: web-gateway
    namespace: ngf-gatewayapi-ns
    sectionName: http
  hostnames:
  - "iphone.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: iphone-svc
      port: 80
```

**Status**

```
Status:
  Parents:
    Conditions:
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               The route is accepted
      Observed Generation:   1
      Reason:                Accepted
      Status:                True
      Type:                  Accepted
      Last Transition Time:  2025-11-20T14:24:39Z
      Message:               All references are resolved
      Observed Generation:   1
      Reason:                ResolvedRefs
      Status:                True
      Type:                  ResolvedRefs
    Controller Name:         gateway.nginx.org/nginx-gateway-controller
    Parent Ref:
      Group:         gateway.networking.k8s.io
      Kind:          Gateway
      Name:          web-gateway
      Namespace:     ngf-gatewayapi-ns
      Section Name:  http
```
