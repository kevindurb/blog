---
title: I Run Kubernetes Btw
date: 2025-01-24
---

Its been quite a while since i've posted here so I think its about time i gave
a homelab update! So we're gonna talk about what my homelab used to be, the pain
points I had with that setup and where I am now and why!

## What my homelab used to be

My homelab has gone through a bunch of changes over the years I've had it. I
started out with one lonely Dell R610 that ran Proxmox with vms running containers.
That lasted actually quite a while with me adding a couple Dell R620's to increase
my compute capacity. I was always short on storage so each of the blade servers
only had a few HDDs in them.

I really enjoy just completely changing my homelab to learn new things so one of
the changes I made shortly after getting the blade servers was to see if I could
more constrain my setup to less energy, space and compute usage. I bought three
Raspberry Pi 4's (very new at the time) and moved my entire lab onto those pis.
I believe at the time I was running ubuntu on all the pis and provisioning
docker-compose stacks onto them with ansible. This was a super fun setup since
it was soooo quiet and felt so simple to me. But some of the problems with this
setup was exactly why I tried it in the first place. I ran out of compute resources
rather quickly.

After this experiment I switched back to my blade servers running proxmox and provisioning
vms with ansible. It was a great stack but so resource intensive for just running
the containers I wanted to run. Also the R610 and R620 were getting old. The R610's
raid controller only worked on ubuntu since RHEL had retired including the drivers.
They where also soooooo loud. At the time I kept the blades in my office and I
was getting very tired of the constant humm in the background.

After running vms with containers for a while I was talking to a friend who runs
kubernetes for his homelab and he finally convinced me to switch mine over.

## Why Kubernetes??

To answer this question we need to walk through what I use my homelab for. This
is different for everyone of course. But for me the biggest part of having a homelab
is learning. I want a place that I can easily deploy containers for everything
from personal projects to my media stack. I enjoy swapping out apps for different
apps to mess with things. Kubernetes lets me put a couple computers together into
a cluster and then just use yaml to describe the containers I want to run, the
networking I want, the configuration I want, everything. Changing things out is
as easy as just changing lines of text and waiting for it to deploy. This is probably
so appealing to be because I'm a software engineer and love infrastructre as code.

## Whats my homelab now?

I've inherited a few more discarded computers from work that ive turned into a
kubernetes cluster! I'm running 4 more traditional computers in 2U rack mount cases.
Each node has an i5-4590 and 16GB of ram. Each machine also has a GPU, 3 of them
have GTX-750Tis which I got with the machines from work and one has my old gaming
GPU which is a GTX-1060 6GB. The older GPUs are honestly pretty useless at this point.
They can do a minimal amount of transcoding at 1080p60 but thats pretty much it.
The GTX-1060 is actually quite useful tho! I run various LLMs on it and do all
my transcoding on it. All my kubernetes manifests are open source on my github
[go check them out!](https://github.com/kevindurb/infra)

Anytime I make changes to my manifests the instance of ArgoCD I have running in
my cluster picks up those changes and automatically applies them which gives me
a really great process similar to what im used to as a software engineer.

## What now?

Well at this point my kubernetes cluster is constantly in flux, but thats why it
exists! I'm constantly changing how I manage persistent storage, secrets, etc,
and Kubernetes lets me do that! If you havent gotten a chance to explore kubernetes
yet I'd say... well dont... probably... Heres the deal, if you dont yet understand
how containers work, how dns works, and like a ton of other topics then kubernetes
is just not for you yet... Go explore building and running containers in a simpler way
with like docker compose before you dive into kubernetes! I'm a firm believer in
the "Learn (x) the hard way" mantra, but thats probably for another blog post...
