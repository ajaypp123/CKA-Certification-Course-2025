
# Day 39

### Custom Resource
- It is extention resources not provided in api-resource
- It is Declerative when paired with controller.
- It requeired CRD

### Custom resource Defination (CRD)
- specify all format and defition of fields
- use documentation to build CRD
```sh
kubectl explain pods
kubectl explain pods.spec
```

### Custom Controller
- we can add custome controller to custom resource to watch and take action on events
- It is written in go
- It observer current state and if any change happens it will bring to desigered state

### Example

- crd

```yaml
# Defines a new custom resource type in the Kubernetes API
apiVersion: apiextensions.k8s.io/v1        # Required API version for CRD definitions since Kubernetes v1.16+
kind: CustomResourceDefinition             # Specifies that we're defining a custom resource type

metadata:
  name: backuppolicies.ops.cloudwithvarjosh  # Must be <plural>.<group>; uniquely identifies the CRD cluster-wide

spec:
  group: ops.cloudwithvarjosh             # Defines the API group used in the resource's apiVersion (e.g., ops.cloudwithvarjosh/v1)

  names:
    plural: backuppolicies                # Plural form used in CLI and API endpoints (e.g., /apis/ops.cloudwithvarjosh/v1/backuppolicies)
    singular: backuppolicy                # Optional: Singular name used in output and CLI messages
    kind: BackupPolicy                    # Required: PascalCase identifier used as the `kind` field in manifests
    shortNames:
      - bp                                # Optional: Short alias for CLI (e.g., `kubectl get bp`)

  scope: Namespaced                       # Determines resource scope: 'Namespaced' means one per namespace (vs. 'Cluster')

  versions:
    - name: v1                            # Version name (used in apiVersion of custom resource instances)
      served: true                        # Exposes this version via Kubernetes API
      storage: true                       # Persists data in etcd using this version's schema

      schema:
        openAPIV3Schema:                  # Defines schema validation rules for the resource
          type: object                    # The top-level object must be a JSON object (map)

          properties:
            spec:                         # The `.spec` field defines user intent (like in Deployments)
              type: object
              properties:

                schedule:
                  type: string
                  description: >          # Cron-formatted string for triggering backups
                    Defines when the backup should run using standard cron syntax.
                    Example: "0 1 * * *" runs every day at 1:00 AM.

                retentionDays:
                  type: integer
                  description: >          # Retention policy for old backups
                    Number of days to keep completed backups before automatic deletion.
                    Helps manage storage usage and retention compliance.

                targetPVC:
                  type: string
                  description: >          # Name of the PersistentVolumeClaim (PVC) to back up
                    Points to the storage volume to snapshot or archive.
                    Commonly used for application or database data.
```

# Day 40

### Operators

- custom controller + a Custom Resource (CR) together form an Operator.
- For CR controller only watch but in operator it can do custom operation and automation.

### What Is a Kubernetes Operator?

![Alt text](/images/40c.png)

### Operator use case

- Operator used for fackup, failover, monitor, and multiple backend operations.

When most people first hear about Kubernetes Operators, they think of them only in the context of **databases** or **stateful apps**. But the reality is:

> **Operators are a general-purpose automation pattern** — they can be built for almost anything.

Whether you're managing:

* **Databases** (e.g., MySQL, PostgreSQL, MongoDB)
* **Monitoring systems** (e.g., Prometheus, Thanos)
* **Security tools** (e.g., cert-manager for TLS, Kyverno for policy enforcement)
* **Backup systems** (e.g., Velero)
* **Networking components** (e.g., Istio, Cilium)
* **CI/CD platforms** (e.g., ArgoCD, Flux)

There’s likely an Operator for it — and it doesn’t stop there. You can build **custom Operators** for **internal applications**, **SaaS integrations**, or **company-specific logic**.

> 🎯 A good rule of thumb: **If something needs to reconcile desired vs actual state continuously, it’s a good fit for an Operator.**

Want to explore what’s already out there? Check out [OperatorHub.io](https://operatorhub.io) — a central registry of community and vendor-supported Operators across domains.

### How to create operator


Creating Operators may sound intimidating, but several frameworks and tools exist to **simplify and accelerate** the process — whether you're writing in Go, Python, Ansible, or even Helm.

### Popular Operator Development Frameworks

| Tool / SDK                 | Language                          | Description                                                                                             |
| -------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Operator SDK (Go)**      | Go                                | Official CNCF-backed SDK for building production-grade Operators using controller-runtime               |
| **Kubebuilder**            | Go                                | A scaffolding tool for writing native Kubernetes APIs/controllers (used by Operator SDK under the hood) |
| **Operator SDK (Ansible)** | Ansible                           | Write Operators using Ansible playbooks instead of code                                                 |
| **Operator SDK (Helm)**    | YAML/Helm                         | Use existing Helm charts to create Operators without writing code                                       |
| **Metacontroller**         | Any language (JSON over webhooks) | Lightweight tool for building custom controllers using webhooks and templates                           |
| **Java Operator SDK**      | Java                              | Build Operators using familiar Java frameworks like Quarkus or Spring Boot                              |

---

# Day 42

### KUSTOMIZE

![Alt text](/images/42b.png)

```sh
->$ tree demo1/
demo1/
├── base
│   ├── deploy.yaml
│   ├── kustomization.yaml
│   └── svc.yaml
└── overlays
    ├── dev
    │   └── kustomization.yaml
    ├── prod
    │   └── kustomization.yaml
    └── stage
        └── kustomization.yaml
```

- `kustomization.yaml` have transformer to update values at runtime.

```sh
# Show yaml
kubectl kustomize demo1/overlays/dev/
kubectl kustomize demo1/base/

# Apply chart
kubectl apply -k demo1/overlays/dev/
```

- kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Reference to shared base
resources:
  - ../../base

# Optional: Apply name prefix/suffix
nameSuffix: -dev
```

### Patches