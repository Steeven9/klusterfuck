# klusterfuck

A Kubernetes learning experience.

The goal: set up a simple Kubernetes cluster with gitops and deploy some apps. How hard can it be?

Features:

- HA deployments (at least two replicas for each app)
- Gitops with automatic reconciliation
- Network policies (default deny) to harden communication
- Some basic security hardening (e.g. pods running as non-root)
- Easy ingress configuration

Limitations:

- no auto-upgrade for k3s ([could be done with some more yaml](https://docs.k3s.io/upgrades/automated))
- all the apps I develop myself don't have Helm charts so we need to manage all the components individually
- no service mesh (on purpose to keep things simple)
- control plane is not HA (by design)
- still have to figure out secrets management
- still have to test the NFS storage

## Structure

The configuration management is done with [Flux](https://fluxcd.io/flux/get-started) via this git repo, so each `git push` is applied to the cluster directly.

The `cluster/apps` folder holds the deployment manifests for each application, while the rest is the base infra (Flux, NFS storage provider, ...).

Exposure is done with an Nginx reverse proxy in front of the cluster, which also load-balances between the two nodes, and Traefik running in the cluster for the routing (it came with k3s so we're just gonna roll with that).

## Setup

### Requirements

At least two machines - I went with two Raspberry Pi 3B because that's what I had around, installed Raspberry Pi OS Lite with the [Raspberry Imager](https://www.raspberrypi.com/software/), and then did some basic hardening.

Disclaimer: *ideally* there should be at least two control plane nodes to keep the k8s API server available even if one node goes down. I think we can live without that, but this is not a prod-ready setup!

To use external storage, I chose to rely on my existing TrueNAS SCALE installation, with a dedicated dataset, and the [NFS provider](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) in the cluster.

### Installation

For the installation steps, see `docs/setup.md`.

Note: I had to disable `ufw` entirely because I cannot figure out which ports k8s is upset about lol

## Achievements

- ✅ get burned by UFW blocking some connectivity
- ✅ assign the wrong scopes to the GitHub token (curse you, least-privilege principle)
- ✅ forget to add resources in the kustomization and wonder why they're not appearing
- ✅ forget that Raspberry Pi uses arm architecture and therefore needs specific arm64-built images
- ✅ get burned by a network policy set on the wrong port and therefore blocking connectivity

## Pain points

- configuration bloat: currently sitting at 6400 lines of YAML just for a single webapp
- configuration drift: if I add e.g. a new security feature for a deployment, I have to remember to manually add it to the other ones as well
- different platform: Raspberry Pis need dedicated images built for arm64, which means adding steps in the CI
- resource limits: `kubectl get pods -A` takes 13 seconds to execute on the Pi itself, and the system as a whole feels way slower (SSHing, running commands, etc.)
