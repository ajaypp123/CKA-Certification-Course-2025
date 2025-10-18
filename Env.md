Here are the **different ways to provide environment variables** (`env`) in Kubernetes Pods/Containers 👇

---

### 🧩 1. **Static key-value**

```yaml
env:
- name: ENV_NAME
  value: "production"
```

➡️ Hardcoded value directly in the manifest.

---

### 📋 2. **From Pod fields (Downward API)**

```yaml
env:
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
```

➡️ Gets runtime info like Pod name, namespace, or IP.

---

### ⚙️ 3. **From Resource fields (Downward API)**

```yaml
env:
- name: CPU_LIMIT
  valueFrom:
    resourceFieldRef:
      containerName: myapp
      resource: limits.cpu
```

➡️ Gets container resource limits/requests.

---

### 🗂️ 4. **From ConfigMap (single key or all keys)**

**a) Single key**

```yaml
env:
- name: APP_MODE
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: mode
```

**b) All keys**

```yaml
envFrom:
- configMapRef:
    name: app-config
```

➡️ Injects key-value pairs from a ConfigMap.

---

### 🔐 5. **From Secret (single key or all keys)**

**a) Single key**

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

**b) All keys**

```yaml
envFrom:
- secretRef:
    name: db-secret
```

➡️ Injects sensitive data from a Secret.

---

### ⚡ 6. **From projected sources (advanced)**

```yaml
envFrom:
- secretRef:
    name: common-secrets
- configMapRef:
    name: shared-config
```

➡️ Combines ConfigMap + Secret + Downward API in one Pod spec.

---

✅ **Summary Table**

| Source Type   | Method                        | Example         |
| ------------- | ----------------------------- | --------------- |
| Static value  | `value`                       | `"production"`  |
| Pod metadata  | `fieldRef`                    | `metadata.name` |
| Resource info | `resourceFieldRef`            | `limits.cpu`    |
| ConfigMap     | `configMapKeyRef` / `envFrom` | `app-config`    |
| Secret        | `secretKeyRef` / `envFrom`    | `db-secret`     |

---
