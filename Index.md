## CKA Certification Course — Day-wise Index

Below is a consolidated index of the course. Each day links to the detailed notes and demo files in the corresponding folder.

<!-- Usage: click a day to open its README -->

### [Day 01 — Docker Fundamentals for Kubernetes](Day 01/README.md)
	- What is Docker and why use it
	- Images vs containers vs registries
	- Docker Engine, CLI, and basic workflow (build/push/run)

### [Day 02 — Write Your First Dockerfile, and Push to Docker Hub](Day 02/README.md)
	- docker pull and registries (Docker Hub, ECR, GCR)
	- Create Dockerfile, build, tag and push image
	- Common docker commands (images, ps, run)

### [Day 03 — Docker Flags, Deep Dive into Dockerfile, and Exposing Containers](Day 03/README.md)
	- Important docker run flags (-d, -p, --name)
	- Dockerfile instructions: FROM, RUN, COPY, ADD, EXPOSE, CMD, ENTRYPOINT
	- Shell vs exec form for CMD/ENTRYPOINT

### [Day 04 — Docker Flags, Deep Dive into Dockerfile, and Exposing Containers (additional)](Day 04/README.md)
	- Custom Dockerfile names and build contexts (-f)
	- CMD vs ENTRYPOINT behavior and best practices
	- Optimizing build context with .dockerignore

### [Day 05 — Docker Multi-Stage Builds & Image Optimization](Day 05/README.md)
	- Compiled vs interpreted languages and build/runtime stages
	- Multi-stage Dockerfiles to produce small runtime images
	- Layer creation, minimizing layers, and best practices

### [Day 06 — Hello Kubernetes! Why Kubernetes? What is Kubernetes?](Day 06/README.md)
	- Why Kubernetes vs Docker alone (auto-scaling, self-healing)
	- Kubernetes vs Docker Swarm vs Docker Compose
	- High-level Kubernetes features and use cases

### [Day 07 — Kubernetes Architecture & Deployment Creation Workflow](Day 07/README.md)
	- Pods, ReplicaSets, Deployments and control plane vs data plane
	- etcd, API server, Scheduler, Controller Manager, kubelet, kube-proxy
	- Deployment workflow: kubectl apply -> API server -> controllers -> kubelet

### [Day 08 — Setting Up Kind Cluster Locally & Kubernetes Context](Day 08/README.md)
- kind create cluster (config vs CLI)
- kind cluster config (nodes, images, extraPortMappings)
- kubeconfig, contexts, switching, merging kubeconfigs
- kubectl config view/get-contexts/use-context/set-context

### [Day 09 — YAML Tutorial for Kubernetes | Imperative vs Declarative](Day 09/README.md)
- Imperative vs declarative approaches (kubectl run vs kubectl apply -f)
- YAML basics: scalars, lists, dictionaries, indentation
- Pod manifest examples and common kubectl pod commands

### [Day 10 — Replication Controller, ReplicaSets, and Deployment](Day 10/README.md)
- kubectl api-resources
- ReplicationController concept, labels & selectors
- ReplicaSet and set-based selectors (matchLabels/matchExpressions)
- Deployments, rolling updates, rollbacks and revision history

### [Day 11 — Microservices & 3-Tier Architecture | Software Design for Kubernetes](Day 11/README.md)
- 3-tier architecture: frontend, middleware, backend, database
- Monolith vs microservices benefits and tradeoffs
- Mapping microservices to Kubernetes (Deployments, Services, StatefulSets)

### [Day 12 — Kubernetes Services IN-DEPTH | ClusterIP, NodePort, LoadBalancer, ExternalName](Day 12/README.md)
- Why Services are needed (stable endpoints, service discovery)
- ClusterIP (internal), NodePort (external via node:port), LoadBalancer, ExternalName
- Kind + NodePort extras (extraPortMappings) and service request flow

### [Day 13 — Imperative commands for Deployments, Services and Troubleshooting](Day 13/README.md)
- Use imperative kubectl to generate YAML (kubectl create deployment/run/expose)
- dry-run modes, -o yaml output, quick troubleshooting pods (--rm -it)
- limitations of imperative flags (nodePort must be added in YAML)

### [Day 14 — Kubernetes Namespaces Explained | Isolation & Resource Management](Day 14/README.md)
- What namespaces are and default namespaces (default, kube-system, kube-public)
- Create/list/delete namespaces, -n and -A flags
- Namespace isolation, resource quotas, setting default namespace in context
- Setting default namespace

### [Day 15 — Manual Scheduling & Static Pods](Day 15/README.md)
- Manual scheduling with spec.nodeName to place pods on a specific node
- Static pods (kubelet-managed, /etc/kubernetes/manifests) and mirror pods
- Use cases for manual scheduling and static pods

### [Day 16 — Mastering Kubernetes Taints & Tolerations](Day 16/README.md)
- Taints and tolarance overview and usecase
- Taints on nodes (NoSchedule / PreferNoSchedule / NoExecute)
- Pod tolerations syntax and operators (Equal / Exists)
- How taints + tolerations affect scheduling and eviction behavior

### [Day 17 — Mastering Node Selector & Node Affinity Rules in Kubernetes](Day 17/README.md)
- nodeSelector basics (exact matches) and labeling nodes
- nodeAffinity (required vs preferred) and matchExpressions
- anti-affinity and scheduling strategies

### [Day 18 — Taints & Tolerations vs. Node Affinity | Pod Scheduling Control](Day 18/README.md)
- Compare taints+tolerations with node affinity
- When to combine tolerations + nodeAffinity for strict placement
- Practical examples and gotchas

### [Day 19 — MASTER Kubernetes Requests, Limits & LimitRange](Day 19/README.md)
- Requests vs limits and how they affect scheduling & runtime
- CPU throttling vs OOM kills, resource quotas and LimitRange
- Metrics server requirement for kubectl top and monitoring

### [Day 20 — MASTER Kubernetes Autoscaling | HPA & VPA](Day 20/README.md)
- Horizontal Pod Autoscaler (HPA): metrics, requests required, scaling behavior
- Vertical Pod Autoscaler (VPA): modes, recommendations vs automatic updates
- Cluster autoscaling vs pod autoscaling (Cluster Autoscaler, Karpenter)

### [Day 21 — Multi-Container Pods DEEP-DIVE | Init vs Sidecar vs Ambassador vs Adapter](Day 21/README.md)
- Pod patterns: init containers, sidecars, ambassadors, adapters
- Shared network/volumes, lifecycle differences and common use-cases
- Demos: init container checks, sidecar logging/metrics

### [Day 22 — Kubernetes Pod Termination, Restart Policies, Image Pull Policy, Lifecycle & Common Errors](Day 22/README.md)
- Pod termination (SIGTERM -> grace period -> SIGKILL), force delete
- RestartPolicy: Always / OnFailure / Never and typical usage
- ImagePullPolicy, pod phases, common errors (CrashLoopBackOff, ImagePullBackOff)

### [Day 23 — DEEP-DIVE into Kubernetes Health Probes | Readiness vs Liveness vs Startup](Day 23/README.md)
- Readiness vs liveness vs startup probes and their timers
- How probes affect traffic, restarts, and multi-container pods
- Probe configuration best practices and examples

### [Day 24 — Docker Volumes Explained | Foundation for Kubernetes Persistent Storage](Day 24/README.md)
- Docker storage drivers vs volumes, writable layer vs image layers
- Volume types, persistence, and why volumes are needed for data durability
- Demo: creating and using Docker volumes
-
### [Day 25 — Kubernetes Core & Extensions | CNI, CSI, CRI, Add-Ons & Plugins](Day 25/README.md)
	- Kubernetes core vs extended architecture: control plane and node components
	- Standard interfaces: CNI (network), CSI (storage), CRI (runtime) and common implementations
	- Plugins, add-ons and why a plugin-based architecture improves flexibility and vendor neutrality

### [Day 26 — Kubernetes Volumes | Ephemeral Storage | emptyDir & downwardAPI DEMO](Day 26/README.md)
	- Ephemeral storage concepts and use-cases for emptyDir
	- Downward API: exposing pod metadata via env vars and files (projected volumes)
	- Demos showing emptyDir sharing between containers and Downward API mounts

### [Day 27 — Kubernetes Volumes | Persistent Storage | PV, PVC, StorageClass, hostPath DEMO](Day 27/README.md)
	- PersistentVolumes (PV) and PersistentVolumeClaims (PVC): binding, access modes, reclaim policies
	- StorageClasses and dynamic provisioning vs in-tree drivers vs CSI drivers
	- hostPath and local volumes (behavior on KIND/macOS/Linux) and demo of hostPath

### [Day 28 — Kubernetes ConfigMaps & Secrets Explained](Day 28/README.md)
	- ConfigMaps: decoupling configuration, use as env vars or mounted files
	- Secrets: handling sensitive data, encoding vs encryption, mounting and best practices
	- Live demos: mounting ConfigMaps as files (index.html) and using keyRef/env injection

### [Day 29 — MASTER DaemonSet, Job & CronJob in Kubernetes](Day 29/README.md)
	- DaemonSet: one pod per node use-cases (logging, monitoring, CNI/CSI) and tolerations
	- Job vs CronJob: one-off tasks and scheduled jobs, completions/parallelism/backoff
	- Practical demos: deploying a dummy logging DaemonSet and creating Jobs/CronJobs

### [Day 30 — How HTTPS & SSH Work | Encryption Fundamentals](Day 30/README.md)
	- Encryption fundamentals: symmetric vs asymmetric algorithms and real-world roles
	- TLS (HTTPS) handshake and SSH key-based authentication explained
	- Encryption in-transit vs at-rest and why both are important for cloud security

### [Day 31 — TLS in Kubernetes MASTERCLASS | PART 1](Day 31/README.md)
	- Public key cryptography, client/server roles, and key management (ssh-keygen/openssl)
	- Types of CAs: public, private, and self-signed; trust chains and PKI basics
	- Mutual authentication concepts and TLS 1.3 highlights relevant to Kubernetes

### [Day 32 — TLS in Kubernetes MASTERCLASS | PART 2](Day 32/README.md)
	- kubeconfig structure and contexts: clusters, users, contexts, and common kubectl config commands
	- Mutual TLS (mTLS) overview and why it's used inside Kubernetes clusters
	- Managing multiple kubeconfigs, KUBECONFIG env var, and practical tips for switching contexts

### [Day 33 — TLS in Kubernetes MASTERCLASS | PART 3](Day 33/README.md)
	- Private CAs in clusters, component trust boundaries and when to use multiple CAs
	- Which Kubernetes components act as clients vs servers and how mTLS flows are established
	- Inspecting certs and kubeconfig to troubleshoot TLS issues in-cluster

### [Day 34 — TLS in Kubernetes MASTERCLASS | PART 4](Day 34/README.md)
	- CSR flow for user certificates: generating CSR, CSR object, approval and retrieving certs
	- Creating kubeconfig entries for new users and embedding certs for kubectl
	- RBAC binding and verifying permissions (roles, rolebindings, kubectl auth can-i)

### [Day 35 — MASTER Kubernetes Authorization Modes and Kubernetes API](Day 35/README.md)
	- Kubernetes API overview: /api vs /apis, resource vs non-resource endpoints
	- Authorization modes (RBAC, ABAC, Webhook, NodeRestriction) and the auth pipeline
	- API groups, endpoints and using curl/kubectl proxy for API access and troubleshooting

### [Day 36 — Deep Dive into Kubernetes RBAC Authorization](Day 36/README.md)
	- RBAC primitives: Role, RoleBinding, ClusterRole, ClusterRoleBinding and verbs
	- Namespaced vs cluster-scoped permissions and best practices (least privilege)
	- Examples: binding users, groups, and service accounts; serviceaccount specifics

### [Day 37 — MASTER Kubernetes Service Accounts & Authentication](Day 37/README.md)
	- Authentication methods overview: tokens, client certs, OIDC, webhook token auth
	- ServiceAccount types, projected short-lived tokens (TokenRequest API) and token evolution
	- Best practices: automountServiceAccountToken, least privilege, and CI/CD integration

### [Day 38 — Admission Controllers in Kubernetes | Mutating & Validating](Day 38/README.md)
	- Admission control lifecycle: mutating vs validating admission controllers and execution order
	- Built-in controllers (LimitRanger, PodSecurity, ResourceQuota) and webhook-based policies
	- Policy engines and webhooks: OPA/Gatekeeper, Kyverno, and practical use-cases

### [Day 39 — Custom Resources (CR) and Custom Resource Definitions (CRD) Explained with Demo](Day 39/README.md)
	- CRD basics: extending the API, CR vs CRD, schema (openAPI v3) and application of kubectl explain
	- Controllers and the control-loop pattern: observe, compare, reconcile
	- Demo: create CRD, add custom resource, and how a controller/operator reconciles state

### [Day 40 — Kubernetes Operators Deep Dive with Hands-On Demo](Day 40/README.md)
	- What Operators are: CRDs + custom controllers that encode operational knowledge
	- Operator components: CRD, CR, controller, and how they manage lifecycle tasks (backup, upgrades, failover)
	- Demo overview: installing OLM, deploying an operator (kube-green) and observing automated behavior

### [Day 41 — Pod Security in Kubernetes (Security Context & Linux Capabilities)](Day 41/README.md)
	- Pod & container securityContext fields: runAsUser/runAsGroup, runAsNonRoot, fsGroup, readOnlyRootFilesystem
	- Prevent privilege escalation: allowPrivilegeEscalation, privileged, capabilities management
	- Demos: secure pod manifests and writable-volume patterns using fsGroup

### [Day 42 — Kubernetes Kustomize Explained with Practical Demos](Day 42/README.md)
	- Base + overlays model and `kustomization.yaml` (resources, transformers, nameSuffix)
	- Patching strategies: `patches`, `patchesStrategicMerge`, `patchesJson6902` and transformers
	- When to use Kustomize vs Helm; examples for environment-specific overlays

### [Day 43 — Helm Charts for Beginners (Helm in Kubernetes)](Day 43/README.md)
	- Helm concepts: Charts, Repositories, Releases and values.yaml templating
	- Install/upgrade/rollback lifecycle and release revision history
	- When Helm complements Kustomize: packaging, templating, hooks, and chart distribution

### [Day 44 — MASTER StatefulSets in Kubernetes (Multi-AZ Demo)](Day 44/README.md)
	- Stateful vs stateless: stable identity, ordered pod startup, and per-pod persistent volumes
	- Headless services, stable DNS names, and volumeClaimTemplates for data persistence
	- Production concerns: replication, ordered scaling, and PVC reattachment demos (MySQL example)

### [Day 45 — Pull Private Images in Kubernetes (imagePullSecrets & ServiceAccount)](Day 45/README.md)
	- Image registry types (public vs private) and causes of ImagePullBackOff
	- imagePullSecrets format (`kubernetes.io/dockerconfigjson`) and pod-level vs ServiceAccount-level usage
	- Demo flows: building/pushing private images and configuring SA to provide registry credentials cluster-wide

### [Day 46 — Pod Priority, PriorityClass, and Preemption in Kubernetes](Day 46/README.md)
	- PriorityClass resource and numeric priority values (globalDefault and cluster scope)
	- Scheduler preemption behavior and `preemptionPolicy: Never` option
	- Demo: create priority classes, schedule low/high priority pods and observe preemption

### [Day 47 — Kubernetes Network Policies Explained (Real-World Demo)](Day 47/README.md)
	- NetworkPolicy primitives: podSelector, namespaceSelector, ipBlock and policyTypes (Ingress/Egress)
	- Enforcement depends on CNI (Calico, Cilium, Antrea); KIND needs policy-capable CNI for demos
	- Demo: enforce least-privilege for a 3-tier app (frontend→backend→db) using ingress/egress rules

### [Day 48 — Kubernetes DNS Explained (CoreDNS & Resolution)](Day 48/README.md)
	- CoreDNS roles: cluster DNS service, Corefile, and DNS plugins (kubernetes, pods)
	- FQDN patterns for Services, Pods (optional), and StatefulSet pods via headless services
	- Debugging DNS: /etc/resolv.conf search path, nslookup/dig inside pods, and common troubleshooting steps

### [Day 49 — MASTER Kubernetes Ingress | PART 1 (What, Why & Flow)](Day 49/README.md)
	- Ingress resource purpose: path/host-based HTTP(S) routing and TLS termination at the edge
	- Ingress Controller concept: cloud-native (ALB) vs in-cluster controllers (NGINX, HAProxy, Traefik)
	- Real-world flow: external LB → ingress controller → service → pod; when to use Ingress vs Service types

### [Day 50 — MASTER Kubernetes Ingress | PART 2 (Path-Based Routing on Amazon EKS)](Day 50/README.md)
	- AWS ALB + AWS Load Balancer Controller: IAM policy, service account, and Helm installation steps
	- Demo: path-based routing for /iphone, /android, and catch-all desktop service on multi-AZ EKS
	- Verification and cleanup: target types, ingressClass, and end-to-end checks

- [Day 51 — MASTER Kubernetes Ingress | PART 3](Day 51/README.md)
- [Day 52 — Kubernetes Gateway API Deep Dive | Part 1](Day 52/README.md)
- [Day 53 — Kubernetes Gateway API Demo | Part 2](Day 53/README.md)
- [Day 54 — Build a Multi-Node Kubernetes Cluster with kubeadm + Calico Operator](Day 54/README.md)
- [Day 55 — Upgrade a Multi-Node Kubernetes Cluster with kubeadm](Day 55/README.md)
- [Day 56 — Kubernetes Monitoring & Logging Explained](Day 56/README.md)
- [Day 57 — Kubernetes Control Plane Troubleshooting Guide](Day 57/README.md)
- [Day 58 — Kubernetes Data Plane Troubleshooting Guide](Day 58/README.md)
- [Day 59 — Kubernetes JSONPath with kubectl](Day 59/README.md)
### [Day 51 — MASTER Kubernetes Ingress | PART 3 (TLS & Subdomain Routing on EKS)](Day 51/README.md)
	- TLS termination with ACM and Route 53: request certs, DNS validation, and ALB certificate attachment
	- Ingress annotations for SSL redirect, listener configuration, and ALB health checks
	- Name-based routing (subdomains) and host-based rules; verification and cleanup steps for EKS

### [Day 52 — Kubernetes Gateway API Deep Dive | Part 1](Day 52/README.md)
	- Gateway API concepts: GatewayClass, Gateway, and Route objects (HTTPRoute, TCPRoute, GRPCRoute)
	- Role separation: infrastructure (Gateways) vs application routing (Routes) and multi-protocol support
	- Cross-namespace routing, ReferenceGrant, portability vs controller-specific annotations

### [Day 53 — Kubernetes Gateway API Demo | Part 2 (NGINX Gateway Fabric)](Day 53/README.md)
	- Hands-on NGF demo on KIND: install Gateway API CRDs, deploy NGINX Gateway Fabric via Helm
	- Expose gateway with NodePort, create Gateways and HTTPRoutes, and route to iphone/android/desktop apps
	- Verify flow: NodePort -> Gateway Listener -> HTTPRoute -> Service -> Pods

### [Day 54 — Build a Multi-Node Kubernetes Cluster with kubeadm + Calico Operator](Day 54/README.md)
	- Full kubeadm cluster build: disable swap, install containerd, kubeadm init, join workers
	- Install Calico via Operator; pod network CIDR, Typha, VXLAN notes and troubleshooting tips
	- Verification steps, post-install reboots, and networking/security group recommendations

### [Day 55 — Upgrade a Multi-Node Kubernetes Cluster with kubeadm](Day 55/README.md)
	- Upgrade best practices: versioning (N / N-1 / N-2), sequencing (control-plane first, one node at a time)
	- kubeadm upgrade flow: plan, apply, upgrade kubelet/kubectl on nodes, and post-upgrade validation
	- Backups, Etcd snapshots, CNI compatibility, and draining strategies (rolling, blue/green)

### [Day 56 — Kubernetes Monitoring & Logging Explained](Day 56/README.md)
	- Observability fundamentals: metrics, logs, traces and infra vs application perspectives
	- Metrics-server, Prometheus/Kube-state-metrics, and logging pipelines (Fluentd/Fluent Bit, Loki, EFK)
	- AWS-native options (CloudWatch, AMP, AMG, X-Ray) and guidance for production telemetry

### [Day 57 — Kubernetes Control Plane Troubleshooting Guide](Day 57/README.md)
	- Control-plane anatomy for kubeadm: static pods, mirror pods, and manifests in /etc/kubernetes/manifests
	- Common failures: API server unreachable, etcd health, certificate expiry, scheduler/controller-manager issues
	- High-signal checks and minimal fixes: ss/crictl/logs, manifest corrections, cert rotation, time sync

### [Day 58 — Kubernetes Data Plane Troubleshooting Guide](Day 58/README.md)
	- Data-plane triage order: node/kubelet -> CNI/IPs -> Services/endpoints (kube-proxy) -> DNS -> CSI/storage -> app
	- Frequent issues: Node NotReady, ContainerCreating (CNI), Service/Endpoint problems, CoreDNS failures
	- Quick checks and fixes: kubelet/crictl/journal, CNI DaemonSet, kube-proxy, NetworkPolicies, PVC/CSI diagnostics

### [Day 59 — Kubernetes JSONPath with kubectl](Day 59/README.md)
	- JSON vs YAML: API wire format, JSONPath walks the decoded object tree returned by the API
	- JSONPath essentials: $, ., [*], [index], filters ?(@.field=="val"), and kubectl jsonpath-as-json
	- Practical examples: pods/deployments/services JSONPath extracts and scripting patterns

If you want a shorter view, open the `Day XX/README.md` for more details and demos.
