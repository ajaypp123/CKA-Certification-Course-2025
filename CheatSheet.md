## K8s core and community

![Alt text](/images/25a.png)

## Setup:

- `~/.vimrc`
```sh
set number
set expandtab
set tabstop=2
```

- `~/.bashrc`
```
alias k='kubectl'
```


## 🔑 1. Use `kubectl create --dry-run=client -o yaml`

This is the fastest way to generate a base manifest.
Examples:

```bash
# Pod
kubectl run mypod --image=nginx --restart=Never --dry-run=client -o yaml > pod.yaml

# Deployment
kubectl create deployment mydep --image=nginx --replicas=3 --dry-run=client -o yaml > dep.yaml

# Service
kubectl expose deployment mydep --port=80 --target-port=8080 --type=ClusterIP --dry-run=client -o yaml > svc.yaml
```

Then just edit the YAML with `vim` or `nano`.
👉 This saves you from memorizing full manifests.

---

## 🔑 2. Use `kubectl explain`

If you forget field names or hierarchy:

```bash
kubectl api-resources
kubectl explain pod.spec.containers
kubectl explain deployment.spec.strategy
kubectl explain service.spec.ports
```

It shows schema, required fields, and descriptions.

---

## 🔑 3. Keep Patterns in Mind

Most manifests follow the same skeleton:

```yaml
apiVersion: <group/version>
kind: <ResourceKind>
metadata:
  name: <name>
spec:
  ...
```

If you know **Pod, Deployment, Service**, you can adapt them to StatefulSet, DaemonSet, Job, etc.

---

## 🔑 4. Practice with Shortcuts

* Abbreviations work (`po` for Pod, `svc` for Service, `deploy` for Deployment).
* You don’t need the entire manifest memorized, just **key fields**:

  * Pod: `containers[].image`, `ports`
  * Deployment: `replicas`, `selector`, `template`
  * Service: `ports[].port`, `targetPort`, `type`
  * PV/PVC: `storageClassName`, `accessModes`, `resources.requests.storage`
  * Ingress: `rules`, `backend`

---

## 🔑 5. Bookmark Allowed Docs

During exam, you can use [Kubernetes.io docs](https://kubernetes.io/docs/) (but no Google).
Know where the YAML examples live:

* Pods → [https://kubernetes.io/docs/concepts/workloads/pods/](https://kubernetes.io/docs/concepts/workloads/pods/)
* Deployments → [https://kubernetes.io/docs/concepts/workloads/controllers/deployment/](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* Services → [https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)
* Storage → [https://kubernetes.io/docs/concepts/storage/](https://kubernetes.io/docs/concepts/storage/)

---

## 🔑 6. Practice Muscle Memory

* Daily 30–45 min of `kubectl` practice in a local/minikube/kind cluster.
* Redo manifests until you don’t need to “think”.
* Use labs (like killer.sh or KodeKloud playground).

---

✅ So: **Don’t memorize** → **Generate with `kubectl`** → **Edit only the tricky parts**.

---

👉 Do you want me to create a **cheat sheet of most common manifests** (Pod, Deployment, Service, ConfigMap, Secret, PVC, Ingress) so you have a single page for revision?
