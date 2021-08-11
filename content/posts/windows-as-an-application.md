---
title: "Windows as an Application"
date: 2021-07-26T14:57:01-06:00
draft: true
---
I run linux on everything I can. Currently I'm running Ubuntu on my desktop,
laptop, homelab and even my router! I can do _almost_ everything I could ever
want to do directly, natively on linux, but every once in a while I run into
something that is just better on windows. The wine project has done a fantastic
job adding windows compatability to linux, and the proton project from valve
lets me play 99% of my games on linux! But applications like fusion360 are
almost entirely unusable through wine and the native linux alternatives are just
not as good unfortunately. And there are still some games that just cant be run
through wine. Halo (one of my favorite games) seems to change with every update
as to if it works, sometimes crashes on start, sometimes flawless. And there are
even some games that you can get kicked/banned if you play online via wine! for
the longest time I tried to run as much in linux as I possibly could but
recently I think I have found my current favorite compromise.

## KVM to the rescue... or is it libvirt...? OVMF? vfio? Oh My!
> The Open Virtual Machine Firmware (OVMF) is a project to enable UEFI support for virtual machines. Starting with Linux 3.9 and recent versions of QEMU, it is now possible to passthrough a graphics card, offering the VM native graphics performance which is useful for graphic-intensive tasks.
>
> [Arch Wiki - PCI passthrough via OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)

For quite a while now (since April 2013) the linux kernel has had support to
natively passthrough and entire PCI device to a virtual machine. This can give a
virtual machine access to a real GPU at full native speed.
