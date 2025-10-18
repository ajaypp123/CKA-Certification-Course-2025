kubectl taint node cka-cluster-worker color=blue:NoSchedule
kubectl taint node cka-cluster-worker2 color=green:NoSchedule
kubectl describe node cka-cluster-worker2 | grep Taint
kubectl describe node cka-cluster-worker | grep Taint
