---
title: "DNS via Ansible"
date: 2020-10-14T15:05:20-06:00
draft: true
featured_image: "/servers.jpg"
---
I manage all my self hosted services with ansible (More about that in a future
post, but for now just go check out github.com/kevindurb/infra) and up until
recently ive recently needed to go to three different places
to update dns records to add a new subdomain record for a new docker container
ive just deployed (ex. homeassistant.example.com). I use cloudflare for my dns
so I would start by creating a new `A` record on cloudflare.com. After that
since im hosting all my services from my home internet provider I would need to
go to my router (OPNSense... Another future post...) and add a dynamic dns
updater record to update cloudflare when my home ip address changed. Lastly I
use traefik for a reverse proxy so i would add it there as well. This is a lot
of different locations and every time i would add a new service I would always
forget at least one of them...

Time for a new and better way to do this! After a little research I found out
that ansible has a cloudflare and an ipify module! Ipify lets me fetch my
external ip address and the cloudflare module lets me update my DNS records.
