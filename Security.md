
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

### HTTPS
- HTTPS previously using ssl but now moved to TLS.

![Alt text](/images/30f.png)

# Day 31

### **Public Key Cryptography**  

![Alt text](/images/31-2.png)
