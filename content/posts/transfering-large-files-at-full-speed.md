---
title: "Transfering Large Files at Full Speed"
date: 2021-07-26T14:58:07-06:00
---

So recently i was moving some... linux isos... between my desktop and server and was getting only 65MB/s... I have a wired 1Gb/s ethernet connection between the boxes so i felt like it should be faster... last night i got curious and decided to figure out why i wasnt able to saturate my network and where my bottle neck was... tldr; transfering files via scp/rsync has a ton of overhead...

## Testing Drive Speed
I started by testing disk speeds on both server and desktop with `dd`.

### Write test:
`dd if=/dev/zero of=/path/to/disk/testfile bs=2G count=1`

### Read test:
`dd if=/path/to/disk/testfile of=/dev/null bs=2G count=1`

### Results:
- Desktop nvme: ~3.8GB/s Read, ~2.2GB/s Write
- Server zfs pool: ~1GB/s Read, 603 MB/s Write

Not wildly fast but even with the 600 MB/s write on the zfs pool i should totally be able to saturate a 1Gb/s network... next up testing my network...

## Testing Network Speed
The fantastic `iperf3` tool was a super easy way to test the network speed
between my desktop and server.

### Running iperf3
- iperf3 in server mode on homelab: `iperf3 -s`
- iperf3 in client mode on desktop: `iperf3 -c 192.168.100.1 -p 5201 -P 20`

10 tests and 20 threads put me at a solid 112MB/s. so iperf can solidly saturate my 1Gb/s network... my disks can read and write a 2GB file plenty fast to saturate the network... what gives?? a little internet searching and i found a very helpful unix stackexchange article!

## The Problem
https://unix.stackexchange.com/questions/48399/fast-way-to-copy-a-large-file-on-a-lan

turns out ssh/scp/rsync all have a ton of overhead and the fastest way to push a file over lan is via netcat!

## The Solution
- destination (homelab): `nc -q 1 -l -p 1234 | pv -pterb -s 2G | tar xv`
- source (desktop): `tar cv ~/testfile | nc 192.168.100.1 1234`

The server command sets up a netcat process listening on port 1234 an then when it gets data it pipes it though pipeviewer so we can see the speed and progress then uncompresses it via tar. Client command compresses the file via tar then sends it over netcat to the server on port 1234

With this I got a solid 111 MB/s and saturated my network sending the 2GB test file!
