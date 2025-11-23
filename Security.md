
# Day 30:

### Encryption
1. Symmetric: same key. eg: AES
- for large bulk data like db

2. Asymmetric: different key. eg: RSA
- for TLS, SSH

### Encryption Approch
1. In Transit (moiving data) (ASymmetric)
- Inplemented by TLS and mTLS for service mesh (Asymmetric)
- for k8s communication

2. Rest (not moining data) (Symmetric)
- Implemented by AES
- used in db, etcd, volume, secret

### SSH
- ssh-keygen generate pub and private key
- public key is shared with client and user sigh data with private key and send to client.
- client dycrupt data with pub key

- first session-key generated and pub key transerd to server
- then communication happens with pub and private key.

![Alt text](/images/31-3.png)

### HTTPS
- HTTPS previously using ssl but now moved to TLS.
- certificate agency can be private, public or self signed.
![Alt text](/images/30f.png)

# Day 31

### **Public Key Cryptography**  

![Alt text](/images/31-2.png)

# Day 32

### **mTLS**
- Both client and server need to provide identity, where server provide its identity first.
- in k8s all comunnication happens with mTLS.

![Alt text](/images/32a.png)

### **Kubeconfig and users**
- Context binds cluster and users
- As per mTLS both cluster and user have certificate to prove identity

![Alt text](/images/31-9.png)

- Example file as per above image
```yaml
apiVersion: v1
# Define the clusters
clusters:
  - name: dev-cluster  # Logical name for the development cluster
    cluster:
      server: https://dev-cluster-api-server:6443  # API server endpoint (usually port 6443)
      certificate-authority-data: <certificate-data>  # Base64-encoded CA certificate
  - name: staging-cluster
    cluster:
      server: https://staging-cluster-api-server:6443
      certificate-authority-data: <certificate-data>
  - name: prod-cluster
    cluster:
      server: https://prod-cluster-api-server:6443
      certificate-authority-data: <certificate-data>

# Define users (credentials for authentication)
users:
  - name: seema  # Logical user name
    user:
      client-certificate-data: <client-cert-data>  # Base64-encoded client certificate
      client-key-data: <client-key-data>  # Base64-encoded private key

# Define contexts (combination of cluster + user + optional namespace)
contexts:
  - name: seema@dev-cluster-context
    context:
      cluster: dev-cluster
      user: seema
      namespace: app1-dev-ns  # Default namespace for this context; kubectl commands will run in this namespace when this context is active
  - name: seema@staging-cluster-context
    context:
      cluster: staging-cluster
      user: seema
      namespace: app1-staging-ns  # When this context is active, kubectl will run commands in this namespace
  - name: seema@prod-cluster-context
    context:
      cluster: prod-cluster
      user: seema
      namespace: app1-prod-ns

# Set the default context to use
current-context: seema@dev-cluster-context

# -------------------------------------------------------------------
# Explanation of Certificate Fields:

# certificate-authority-data:
#   - This is the base64-encoded public certificate of the cluster’s Certificate Authority (CA).
#   - Used by the client (kubectl) to verify the identity of the API server (ensures it is trusted).

# client-certificate-data:
#   - This is the base64-encoded public certificate issued to the user (client).
#   - Sent to the API server to authenticate the user's identity.

# client-key-data:
#   - This is the base64-encoded private key that pairs with the client certificate.
#   - Used to prove the user's identity securely to the API server.
#   - Must be kept safe, as it can be used to impersonate the user.

# Together, these enable secure mutual TLS authentication between kubectl and the Kubernetes API server.
```

### User communication to kubernetes via mTLS

![Alt text](/images/31-12.png)


# **Day 33**:

## **Certificate Authority in kubernetes**:
- Certificate Authority responsible for providing, validating and sigining certificate for kubeernetes communication using `mTLS`.

- **There are 2 CA**
1. Private CA:
  - kubernetes generate private CA during initalization.
  - kubernetes create multiple private CA for isolation.
  - As given below etcd have different CA, so even if any other CA compromised etcd still be protected.

![Alt text](/images/33b.png)

2. Public CA
  - Application using ingress, gateway are using public CA.

## Self sigined Certificate
- If issuer and subject of certificate is same then it is self signed certificate
- certificate authority certificate are self signed with root trusted CA.
- root trusted ca mean root CA of Certificate Authority.

## **Certification and CA of all k8s component:**

### Menifest of all kubectl components 
- `/etc/kubernetes/manifests` Here you will find all k8s component yaml.
- `etcd`, `apiserver`, `controller`, `shedular` are in control plane.
- `proxy` and `kubelet` in worker node.

### Communication of all k8s components via mTLS

![Alt text](/images/33c.png)

- Here in above all communication happens with mTLS.
- If scheduler need to communicate to api-server:
  a. api-server (server) will provide signed certificate to scheduler
  b. scheduler (client) verify certificate using certificate authority, then provide its own signed certificate to api-server
  c. api-server similarly verify certificate
  d. once both verified then session will be estabilished.

**Key in communication**
1. **mTLS**: communication protocol
2. **client**: Then one who is sending request. It can be user, scheduler, controller, etc.
3. **server**: The one who serve request. It can be scheduler, api-server, controller, etc.
4. **kubeconfig**: all client need kubeconfig for communication which can be find in menifest, of scheduler, controller, kube-proxy, etc.
5. **certificate**: component certificate
6. **certificate aauthority**: certificate authority which issue and verify certificate.

### Test

1. kube-apiserver
```sh
# Certificate files
$ cat kube-apiserver.yaml | grep tls-cert-file
- --tls-cert-file=/etc/kubernetes/pki/apiserver.crt

# kubeconfig
# As kube-apiserver not acts as client, it is not having any kubeconfig

# Check CA and Issuer of certificate
$ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text

Issuer: CN = kubernetes             # Certificate Authority is kubernetes
Subject: CN = kube-apiserver        # it is issued to kube-apiserver
X509v3 Subject Alternative Name:    # Alternative name for kube-apiserver
        DNS:cka-cluster-control-plane, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, DNS:localhost, IP Address:10.96.0.1, IP Address:172.19.0.4, IP Address:127.0.0.1
```

2. scheduler
- as sheduler is acts as client it communicate via kubeconfig.
- when it get certificate from api-server, to verify this certificate it should have certificate of api-server certificate authority. (Here as in point 1, CA of kube-apiserver is kubernetes)
- certificate authority of kube-apiserver fount in kubeconfig.

```sh
# kubeconfig for scheduler, which maintain all cmmunication similar to client
$ cat kube-scheduler.yaml | grep "kubeconfig"
    - --kubeconfig=/etc/kubernetes/scheduler.conf

# Certificate of CA of kube-apiserver
$ cat /etc/kubernetes/scheduler.conf | grep certificate-authority-data
    certificate-authority-data: LS0tL.........

# check certificate of CA of kube-apiserver
echo -n LS0tLS1CRU.... | base64 --decode
-----BEGIN CERTIFICATE-----
MIIDBTCCAe2gAwIBAgIIYzHwk2mHSi0wDQYJKoZIhvcNAQELBQAwFTETMBEGA1UE
Mo3lAHO8RETs
-----END CERTIFICATE-----
# Now from this certificate we can check issuer which is kubernetes

# sheduler cert
$  cat /etc/kubernetes/scheduler.conf | grep client-certificate-data
```

- similarly all communication happens by mTLS


# **Day 34**

## Create client user for kubernetes

- files
```shell
ajay-rb.yaml  ajay-role.yaml  ajay.crt  ajay.csr  ajay.key  ca.crt  csr.yaml
```

## TODO

# **Day 35**

## **Kubernetes API Endpoints Overview**
- yellow api runs without auth
- greed deals with all workload and k8s objects
- pink produce prometous metrics
- red is for api-server logs

![Alt text](/images/35c.png)

## **API Groups**

![Alt text](/images/35d.png)

- we can check any object api details by kubectl
```sh
# Here apiversion is <group>/<version>, where if any resource have group empty then it belong to core /api else /apis
# here pods and services belong to /api and jobs, deployment belong to /apis

->$ kubectl api-resources
# NAME       SHORTNAMES   APIVERSION                        NAMESPACED   KIND
pods          po           v1                                true         Pod
services      svc          v1                                true         Service
deployments   deploy       apps/v1                           true         Deployment
cronjobs      cj           batch/v1                          true         CronJob
jobs                       batch/v1                          true         Job
....
```

## **API Paths**

![Alt text](/images/35e.png)

## **Authentication**
- mTLS used for Authentication and authorization achived by below.

### Authentication Modes

1. RBAC
- allow access to user, group, service account

2. ABAC
- static json policy and api-server need restart if modified

3. Webhook
- outsource auth from apiserver to external services like opa, gatekeeper

4. Node
- used internally for kublet to access

5. Allways Allow and Allways Deny
- used in mentanance.

### Locations of modes
- It is defined in kube-apiserver pod menifest
```sh
--authorization-mode=Node,RBAC,Webhook
--authorization-policy-file=/etc/kubernetes/abac-policy.json          # ABAC
--authorization-webhook-config=/etc/kubernetes/webhook-policy.json    # Webhook
```

## Webhook and RBAC

Requirements:
Seema must have permission to create Pods.
The Pod's image must come from registry.pinkcompany.com.

### Scenario 1: Using Node + Webhook Authorizer Only

![Alt text](/images/35a.png)

API server configuration:

```bash
--authorization-mode=Node,Webhook
```

### Scenario 2: Node + Webhook + RBAC (Layered)

![Alt text](/images/35b.png)

API server configuration:

```bash
--authorization-mode=Node,Webhook,RBAC
```

# **Day 36**
- All role and role binding work on ussers, group, service accounts.

## **Role and Rolebinding types**

1. Role
- Only applied at namespace level
- Only work on resource which are namespace scoped
```sh
# Here role can be used for pods and deployments but not for pv

NAME                  SHORTNAMES   APIVERSION  NAMESPACED   KIND
deployments           deploy       apps/v1     true         Deployment
pods                  po           v1          true         Pod
persistentvolumes     pv           v1          false        PersistentVolume
```

2. RoleBinding
- Bond `Role` and `ClusterRole` to user, group, service-accounts
- RoleBinding works with ClusterRole also, this used when we wanted to use same role accross multiple namespace.

3. ClusterRole
- applied on cluster level and work with all namespace scoped
```sh
# Work on all below resources
NAME                  SHORTNAMES   APIVERSION  NAMESPACED   KIND
deployments           deploy       apps/v1     true         Deployment
pods                  po           v1          true         Pod
persistentvolumes     pv           v1          false        PersistentVolume
```

4. ClusterRoleBinding
- bind clusterRole to user, group, service-accounts

## **Object Creation**

- Check details of API Group and verbs
```sh
kubectl api-resources -o wide | grep pods
```

- Create objects
```sh
# Total 3 ways available as below
# 1. role with rolebinding
# 2. clusterrole with clusterrolebinding
# 3. clusterrole with rolebinding

kubectl create role workload-role --verb=create,patch,delete,get,list --resource=pods,deployment --dry-run=client -o yaml > ajay-role.yaml

kubectl create rolebinding workload-rb --role=workload-role --user=ajay --group=dev --dry-run=client -o yaml >> seema-role.yaml

kubectl create clusterrole workload-role --verb=create,patch,delete,get,list --resource=pods,deployment --dry-run=client -o yaml > ajay-role1.yaml

kubectl create clusterrolebinding workload-rb --role=workload-role --user=ajay --group=dev --dry-run=client -o yaml >> ajay-role.yaml
```

# **Day 37**

## Authentication in Kubernetes

![Alt text](/images/37a.png)

1. Static Password File
- need api-server restart
```sh
# csv format
password,username,uid,"group1,group2"

# passwd.csv
mypass,ajay,uid123,"dev,admin"

# API Server
--basic-auth-file=/etc/kubernetes/passwd.csv

# Test
curl -u ajay:mypass https://<cluster-endpoint>:<port>/api
```

2. Static token Based
- create token using openssl
- need api-server restart
```sh
# csv format
token,username,uid,"group1,group2"

# token.csv
adsfadsf,ajay,uid123,"dev,admin"

# API Server
--token-auth-file=/etc/kubernetes/token.csv

# Test
curl -H "Authorization: Baerer adsfadsf" https://<cluster-endpoint>:<port>/api
```

3. Service Account Bearer Token
- JWT token by service account
```sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
curl -H "Authorization: Baerer $TOKEN$" https://<cluster-endpoint>:<port>/api
```

4. Certificate
- Used by user and other component via certificate or kubeconfig file

5. External Identity Providers
- offers sso
- Tools can be OIDC, LDAP, Kerberose, Webhook

### Understanding Who Interacts with a Kubernetes Cluster

![Alt text](/images/37b.png)

### Service Account for default case
- default account token autoroteted by 1 hr
```
>$ kubectl describe sa default 
Name:                default
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```

- token is mounted by default
```
  volumes:
  - name: kube-api-access-fzmvq
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
```

### SA Auth
- as above each pod have ca.crt, token, namespace projected via volume

![Alt text](/images/37d.png)

- api-server as server provide TLS cert and pod have signed cert of kube-apiserver of CA as `ca.crt` file
- Then kube apiserver provide token which signed by api-sever private key

### Types of ServiceAccount Tokens

![Alt text](/images/37e.png)

1. Bound Service Account Token
- used internally
```sh
kubectl create serviceaccount test-bound-sa --dry-run=client -o yaml > bound-sa.yaml
kubectl create role bound-role --verb=get,list --resource=pods,deploy --dry-run=client -o yaml >> bound-sa.yaml
kubectl create rolebinding bound-rb --role=bound-role --serviceaccount=testsa:test-bound-sa --dry-run=client -o yaml >> bound-sa.yaml
kubectl run kubectl-pod --image=bitnami/kubectl:latest --dry-run=client  -o yaml >> bound-sa.yaml

# now pod can list pod, deploy in given namespace only
```

2. Manually requested long lived token
- used externally for long jobs
```sh
kubectl create serviceaccount test-bound-sa --dry-run=client -o yaml > bound-sa.yaml
kubectl create role bound-role --verb=get,list --resource=pods,deploy --dry-run=client -o yaml >> bound-sa.yaml
kubectl create rolebinding bound-rb --role=bound-role --serviceaccount=testsa:test-bound-sa --dry-run=client -o yaml >> bound-sa.yaml

TOKEN=$(kubectl -n testsa create token test-bound-sa --duration=60m)
curl -H "Authorization: Bearer $TOKEN" https://127.0.0.1:44007/api/v1/testsa/pods -k
```

3. Legacy secret Token
- used externally by jobs
```sh
kubectl create serviceaccount test-bound-sa --dry-run=client -o yaml > bound-sa.yaml
kubectl create role bound-role --verb=get,list --resource=pods,deploy --dry-run=client -o yaml >> bound-sa.yaml
kubectl create rolebinding bound-rb --role=bound-role --serviceaccount=testsa:test-bound-sa --dry-run=client -o yaml >> bound-sa.yaml

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-bound-sa-token
  annotations:
    kubernetes.io/service-account.name: test-bound-sa
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl get secret legacy-sc-token -o jsonpath='{.data.token}' -n testsa | base64 -d)
curl -H "Authorization: Bearer $TOKEN" https://127.0.0.1:44007/api/v1/testsa/pods -k
```

# Day 38

### Admission Controller flow

![Alt text](/images/38b.png)

### Admission Controller Types

![Alt text](/images/38c.png)

### webhook + RBAC to allow private image only

![Alt text](/images/38e.png)

# Day 41

## **Pod Security**
- Define SecurityContext
- Enfore Policy

## **Pod Security Ways**

### SecurityContext

1. Pod Level
```sh
fsGroup: Specifies GID that owns mounted volume
```

2. Both (Pod and Container) Level
```sh
runAsUser: UID that container process runs as
runAsGroup: GID that container process runs as
runAsNonRoot: Ensure container not start as root, if default container user is root then must specifiy above values to avoid failure.
```

3. Container Level
```sh
allowPrivilegeEscalation: Prevent container from gaining access even with binary or tools. (sudo, su will fail)
privileged: Give container full access to host
readOnlyRootFilesystem: mounts container root filesystem as read-only.
```

### Linux Capability (at container level)

```sh
CHOWN: change ownership of files by chown
NET_ADMIN: change network settings
SYS_TIME: update container time
```

eg:
```yaml
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop:
            - ALL
          # add:
          #   - NET_ADMIN
          #   - SYS_TIME
```

