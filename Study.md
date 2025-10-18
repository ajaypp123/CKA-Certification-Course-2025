# **Day3**
- args -p, --name, -d for docker
- `docker run -d -p 8080:80 --name my-nginx nginx:latest`

# Day 7

### Control plane
- api: orcastrator to comunicate with all component
- sheduler: shedule k8s resource
- control manager: maintain desigered state
- etcd: key-value store to store k8s current state

### Data Plane
- kubelet: communicate with control plane and shedule pod
- pod: smallets unit that run workload
- kube-proxy: Handle all networking of node and pod

### Sheduler in control plane
- Node selector in menifest
- Taint and Tolerance
- Resource available on nodes

# **Day8**

### Version
- For certification we can check kubernetes version online.
- we can update kindset image to that version

## Documentation
- kubernetes.io/docs and kubernetes.io/blog are available for exam.
- In `kubernetes.io/docs` search cheat

# **Day9**

### Use kubectl run

- with run get yaml and modify further
```sh
kubectl run -h

kubectl run pod my-nginx-pod --image=nginx:latest --labels="app=nginx,myenv=dev" --port=443 --port=80 --dry-run=client -o yaml

kubectl run busybox --image=busybox:latest --command -- sh -c "echo Hello; sleep 5; echo Done"
```

- shell
```yaml
  initContainers:
    - name: busybox-container
      image: busybox:latest
      command:
        - "sh"
        - "-c"
        - "echo 'hello'; sleep 100;"
```


# **Day10**

### Version check for any kind
- we can get `apiVersion`, short name resource.
- example: deployment have kind as `apps/v1` and short name as deploy. mean `kubectl get deploy` also works.
```sh
kubectl api-resources

kubectl api-resources | grep deployment
deployments     deploy       apps/v1        true         Deployment

kubectl explain deployment
kubectl get pods --show-labels
```

### Template for Replication Controller, ReplicaSet

- To implement replicaset and replica controller, use command and then update kind and apiVersion and matchLabels
```sh
kubectl create deploy nginx-deployment  --image=nginx:1.22 --dry-run=client --replicas=3 -o yaml > my-deploy.yaml
```

### matchExpression
- operator are `In`, `NotIn`, `Exists`, `DoesNotExist`
```yaml
selector:
  matchExpressions:
    - key: app-label
      operator: In
      values:
        - val1
        - val2
```

### Rollout
- annotation
```yaml
metadata:
  annotations:
    kubernetes.io/change-cause: "Inital release with nginx 1.19"
```

- Update annotation
```sh
kubectl annotate deployments.apps my-nginx-deploy kubernetes.io/change-cause="Inital commit with 1.19 nginx"
```

# Day12

### ClusterIP FQDN
```sh
backend-svc.test-ns.svc.cluster.local:9090
```

### Enable lb ip for testing 
```
 microk8s enable metallb:192.168.1.245-192.168.1.250
```

### check labels to add in service
```
kubectl get pods --show-labels
```

# Day 14

### kubeconfig file
```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://172.20.216.182:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
current-context: microk8s
users:
- name: admin
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
```

### Update default ns
```yaml
kubectl config set-context --current --namespace=my-default-ns
```

### static pod
- static pods are all pod in kube-system
- it managed by kubelet
- even we create static pod in default, it will be mirrored in kube-system
- on any node /etc/kubernetes/menifest/ we can add menifest it will create static pod

# Day16

- Node have Taint and only tolarate those pod which have tolarance
- Node have Taint and pod have tolaration

### Update node label

```
kubectl edit nodes cka-cluster-worker
kubectl get nodes -l nodeenv=test
```

### Taint

```sh
kubectl describe nodes cka-cluster-control-plane | grep Taint
kubectl taint nodes <node-name> <key>=<value>:<effect>
kubectl taint nodes <node-name> <key>=<value>:<effect>- # Untaint

kubectl taint node cka-cluster-worker color=blue:NoSchedule
kubectl taint node cka-cluster-worker color=blue:NoSchedule-

$ kubectl taint node -l="nodeenv in (test,dev)" storage=ssd:PreferNoSchedule
node/cka-cluster-worker tainted
node/cka-cluster-worker2 tainted

kubectl taint node cka-cluster-worker color=green:NoExecute
```

### Tolerations

```yaml
# pod
spec:
  tolerations:
  - key: "color"
    value: "blue"
    operator: "Equal"
    effect: "NoSchedule"

# Deployment and other workload
template:
  spec:
    tolerations:
    - key: "color"
      value: "blue"
      operator: "Equal"
      effect: "NoSchedule"

# Example
      tolerations:
      - key: storage
        operator: Exists
        effect: PreferNoSchedule
```

### operator in workload:
- Equal: match with value for given key
- Exists: schedule on any node having matching key

### Effect
- NoSchedule: Only new pod will be scheduled on matching toleration.
- PreferNoSchedule: Don't enforce but try new pod to be scheduled on matching toleration.
- NoSchedule: Both existing and new pod scheduled on toleration node.

# **Day17**

### Assign and remove label to nodes

```sh
kubectl label nodes --selector=nodeenv nodeenv- # Remove
kubectl label nodes ck-worker1 nodeenv=test
```

### Node Selector
- for pod it is in `spec.nodeSelector` and for other `spec.template.nodeSelector` 
```yaml
  template:
    spec:
      nodeSelector:
        storage: hhd
```

### Node affinity
- requiredDuringSchedulingIgnoredDuringExecution
```yaml
# hhd or ssd
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: storage
                operator: In
                values:
                - hhd
                - ssd

# hhd or ssd
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: storage
                operator: In
                values:
                - ssd
              - key: storage
                operator: In
                values:
                - hhd
```

- preferredDuringSchedulingIgnoredDuringExecution:
```yaml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: storage
                operator: In
                values:
                - hhd
                - ssd
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 7
            preference:
              matchExpressions:
              - key: storage
                operator: In
                values:
                - hhd
          - weight: 3
            preference:
              matchExpressions:
              - key: storage
                operator: In
                values:
                - ssd
```

# Day 18

### Combination of taint and tolarance
- Suppose we have 10 nodes where first 5 nodes is for project A and other for project B.
- Out of 5 node in A, 2 are dedicated to gpu and and other not.

In such case we need combination of Taint and nodeAffinity to make it work.

```sh
kubectl label nodes cka-cluster-worker project=A
kubectl label nodes cka-cluster-worker2 project=B

kubectl taint node cka-cluster-worker env=gpu:NoExecute
```

- Run pod in Project A on GPU node only
```yml
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: project
                operator: In
                values:
                - A
      tolerations:
      - key: "env"
        value: "gpu"
        operator: "Equal"
        effect: "NoExecute"
```

# Day 19

### Check node and pod resources
```
kubectl top pods
kubectl top nodes
```

### Requests and Limits
- If Memory used by pod higher than limit then kernal through `OOMKilled`
- If cpu requested is more than limit then it will throtteled and kept running with given limit. pod will not be killed, but will not be provided more cpu.
```yml
# K8s 1.3 allow to create it at spec level but generally created at container level
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
      limits:
        cpu: 200m
        memory: 200Mi
```

### unit
- memory: Gi. Mi
- cpu: m, 1, 2, 

### Limitrange
- configure default resources for pod in perticular namesapce
- when creating workload not following lomitrange then k8s through forbiddian error
```sh
# https://kubernetes.io/docs/concepts/policy/limit-range/
kubectl apply -f limitrange.yaml
kubectl get limitranges
kubectl describe limitranges cpu-resource-constraint
```

# Day20

- K8s support Horizantal scaling and Vertical scaling where vertical scaling need pod restart.

![Alt text](/images/20b.png)


```sh
# Manual
kubectl scale deployment nginx-deploy --replicas=2

kubectl autoscale deployment nginx-deploy --max=4 --min=2 --cpu=50% --memory=50% --dry-run=client --name=nginx-hpa  -o yaml

kubectl autoscale deployment nginx-deploy --max=4 --min=2 --cpu=50m --memory=50Mi --dry-run=client --name=nginx-hpa  -o yaml
```

- vpa yaml
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: nginx-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       Deployment
    name:       nginx-deploy
  updatePolicy:
    # updateMode options:
    # "Off"     - VPA only recommends resources, does NOT apply them.
    # "Initial" - VPA sets recommended resources at pod creation, no changes after.
    # "Auto"    - VPA automatically updates resources and restarts pods as needed.
    updateMode: "Auto"
```

# Day 23

### Termination grace period
- sends `SIGTERM` signal
```yaml
spec:
  terminationGracePeriodSeconds: 30
```

### force delete
- sends `SIGKILL` signal
```sh
kubectl delete pod nginx --grace-period=0 --force=true
```

### Restart policy
- `Always` restart pod always even if job completed
- `Never` never restart pod and wait for debug and solve issue
- `OnFailure` restart when failed, but not when job completed

```yaml
  template:
    metadata:
      labels:
        app: web-server
    spec:
      restartPolicy: Always
```

### ImagePullPolicy

- `Never`
- `Always`
- `IfNotPresent`

```yaml
  containers:
  - name: my-app
    image: myrepo/my-app:v1.2.3
    imagePullPolicy: Never
```

# Day 23

### **Probe Mechanisms**

![Alt text](/images/23c.png)

### Probe Timer Configuration Parameters

| **Property**          | **Meaning**                                                    | **Default Value** | **Example**                              |
|----------------------|----------------------------------------------------------------|-------------------|------------------------------------------|
| `initialDelaySeconds` | Wait time before first probe starts after container starts     | `0` seconds       | `initialDelaySeconds: 5` → starts after 5 sec |
| `periodSeconds`       | Time interval between probe attempts                           | `10` seconds      | `periodSeconds: 10` → probes every 10 sec   |
| `timeoutSeconds`      | Max wait time for probe response                               | `1` second        | `timeoutSeconds: 2` → fail if no reply in 2 sec |
| `successThreshold`    | No. of consecutive successes needed to mark successful         | `1`               | `successThreshold: 3` → pass after 3 successes |
| `failureThreshold`    | No. of consecutive failures before marking probe as failed     | `3`               | `failureThreshold: 5` → fail after 5 failures  |


### Probes
- startupProbe → Checks if the container has started successfully; used mainly for slow-starting apps.
- livenessProbe → Checks if the container is still running properly; restarts the container if it fails.
- readinessProbe → Checks if the container is ready to accept traffic; removes it from Service endpoints if it fails.

```yaml
 readinessProbe:
   httpGet:
     path: /readyz
     port: 8080
   initialDelaySeconds: 5  # Wait 5 seconds after container starts before probing
   periodSeconds: 10       # Probe every 10 seconds

 livenessProbe:
   exec:
     command:
     - cat
     - /tmp/healthy
   initialDelaySeconds: 3  # Start checking 3 seconds after the container starts
   periodSeconds: 5        # Check every 5 seconds

startupProbe:
  startupProbe:
    tcpSocket:
      port: 9444            # Checks TCP server accessibility on port 9444
    failureThreshold: 15    # Allows up to 15 failed attempts
    periodSeconds: 5        # Probe runs every 5 seconds
```

# Day 26

- emptyDir:
```yaml
# emptyDir
volumes:
- name: temp-dir
  emptyDir:
    sizeLimit: 100Mi
    medium: Memory

# downwardAPI env
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace

# downwardAPI vol
  volumes:
  - name: downwardapi-volume
    downwardAPI:
      items:
      - path: "labels"
        fieldRef:
          fieldPath: metadata.labels
      - path: "annotations"
        fieldRef:
          fieldPath: metadata.annotations
```

# Day 27

- storageClassName: "" # Empty string must be explicitly set otherwise default StorageClass will be set

### volumeMode
- Block
- Filesystem	
- unspecified

### **Choosing the Right Reclaim Policy**  

| **Reclaim Policy** | **Behavior** | **Best Use Case** | **Common in** |
|-------------------|------------|-----------------|----------------|
| **Delete** | Deletes PV and storage resource when PVC is deleted. | Cloud-based dynamically provisioned storage. | AWS EBS, GCP PD, Azure Disk. |
| **Retain** | Keeps PV and storage, requiring manual cleanup. | Backup, auditing, manual data recovery. | On-prem storage, long-term retention workloads. |
| **Recycle (Deprecated)** | Cleans volume and makes PV available again. | (Not recommended) | Previously used in legacy systems. |

### accessModes
**ReadWriteOnce (RWO)**
**ReadOnlyMany (ROX)**
**ReadWriteMany (RWX)**
**ReadWriteOncePod (RWOP)**

### Types
`csi` - Container Storage Interface (CSI)
`fc` - Fibre Channel (FC) storage
`hostPath` - HostPath volume (for single node testing only; WILL NOT WORK in a multi-node cluster; consider using local volume instead)
`iscsi` - iSCSI (SCSI over IP) storage
`local` - local storage devices mounted on nodes.
`nfs` - Network File System (NFS) storage

### HostPath types
- DirectoryOrCreate
- Directory
- FileOrCreate
- File
- Socket
- CharDevice
- BlockDevice

### subPath
- In Kubernetes, subPath is used to mount only a specific folder or file from a volume into a container — instead of mounting the entire volume.

```sh
# hostpath dir structure

# /data/site-data/
# ├── html/
# │   ├── index.html
# │   └── style.css
# └── logs/
#     └── app.log
```

- volumeMount and volumes in workload
```yaml
#  Mounts only /data/site-data/html into /var/www/html inside the Nginx container.

volumes:
- name: site-data
  hostPath:
    path: /data/site-data

volumeMounts:
  - mountPath: /var/www/html
    name: site-data
    subPath: html
  # Mount only the "logs" subdirectory
  - name: site-data
    mountPath: /var/log/nginx
    subPath: logs
```

- Different volume example
```yaml
# hostpath vol
volumes:
- name: host-volume
  hostPath:
    path: /tmp/hostfile
    type: FileOrCreate

# Defination in pv
hostPath:
 path: /tmp/data
 readOnly: true

nfs:
  path: /tmp
  server: 172.17.0.2
  readOnly: true

csi:
  driver: ebs.csi.aws.com
  fsType: ext4
  volumeHandle: {EBS volume ID}
```

### storage class is dynamic volume provisioning
- only create pvc and deploy and then volume will be attached to it.


# Day 28

### Env
- env variable in pod

### Configmap
- cm access with env, file
```sh
kubectl create configmap backend-cm --from-env-file=.env --dry-run=client  -o yaml
# or
kubectl create configmap backend-cm --from-literal=APP=PROD --from-literal=ENV=TEST --dry-run=client  -o yaml

kubectl create configmap nginx-cm --dry-run=client --from-file=index.html --from-literal=APP=BACKEND --from-literal=ENV=TEST  -o yaml
```
- mount
```yaml
# Env
env:
- name: PROD
  valueFrom:
    configMapKeyRef:
      name: nginx-cm
      key: APP
- name: ENV
  valueFrom:
    configMapKeyRef:
      name: nginx-cm
      key: ENV

# volume
volumes:
- name: nginx-conf
  configMap:
    name: nginx-cm

volumeMounts:
- name: nginx-conf
  mountPath: /usr/share/nginx/html/index.html
  subPath: index.html
# or
volumeMounts:
- name: nginx-conf
  mountPath: /usr/share/nginx/html
  readOnly: true

```

### Reflect updated configmap in deployment
```sh
kubectl rollout restart deployment nginx-deploy
```

### Secret
```sh
# create
kubectl create secret generic nginx-sc --from-literal=APP=PROD --from-file=cm_data.json  --dry-run=client -o yaml
kubectl create secret generic nginx-sc --from-env-file=.env --dry-run=client -o yaml

# decode encode
kubectl get secret nginx-sc -o jsonpath={.data.APP} | base64 --decode
echo -n "PROD" | base64
echo -n "UFJPRA==" | base64 --decode

# env
- name: PROD_SC
  valueFrom:
    secretKeyRef:
      name: nginx-sc
      key: APP 

# volume
volumes:
- name: nginx-secret
  secret:
    secretName: nginx-sc

  - name: nginx-secret
    mountPath: /data
```

# Day 29

### DaemonSet
- It runs on all nodes, also created and removed as per node addition and removel
```sh
kubectl create deployment busybox-ds --image=busybox --dry-run=client -o yaml > q1.yaml

# 1. remove replicas
# 2. add tolaration spec.tolerations:  node-role.kubernetes.io/control-plane:NoSchedule op=Exists
# 3. change Deployment to DaemonSet
```

### Jobs
- can run job batch on k8s 
- we can manage parallelism, failure
- copy template from k8s docs

### CronJob
- syntax is similar only difference is schedule field
- we can shedule job to run at perticular times
```yaml
spec:
  schedule: "* * * * *"
  jobTemplate:
    # job spec template
```
