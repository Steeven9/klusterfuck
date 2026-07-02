# klusterfuck

A Kubernetes learning experience

## Requirements

At least two machines - I went with two Raspberry Pi 3B because that's what I had around, installed Raspberry Pi OS Lite with the [Raspberry Imager](https://www.raspberrypi.com/software/), and then did some basic hardening.

To use external storage, I chose to reply on my existing TrueNAS SCALE installation, with a dedicated dataset and the NFS provider.

## Setup

For the installation steps, see `docs/setup.md`.

## Structure

The configuration management is done with [Flux](https://fluxcd.io/flux/get-started) via this git repo, so each `git push` is applied to the cluster directly.

The `cluster/apps` folder holds the deployment manifests for each application, while the rest is the base infra (Flux, NFS storage provider, ...)
