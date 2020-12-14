---
title: "DNS via Ansible"
date: 2020-10-14T15:05:20-06:00
draft: false
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
external ip address and the cloudflare module lets me update my DNS records. A
small ansible script lets me pull my ip address then use that to update the dns
records...
```
  vars:
    zone: kevindurbin.com
    subdomains:
      - heimdall
      - rss
      - hass
      - codimd
      - plex

  tasks:
  - name: Get public ip address
    ipify_facts:

  - name: Add subdomains to dns
    loop: '{{ subdomains }}'
    cloudflare_dns:
      proxied: yes
      zone: '{{ zone }}'
      record: '{{ item }}'
      type: A
      value: '{{ ansible_facts.ipify_public_ip }}'
      account_email: '{{ email }}'
      account_api_token: '{{ cf_api_token }}'
```

Super easy! Now anytime I want add a new container everything i need to update
is in my one github repo! I am missing one piece though. See one of the most
annoying parts of hosting services over a residential internet connection is how
every once in a while my ip address will change. I used to have OPNSense auto
update the cloudflare records anytime the ip changed but now that its all in an
ansible playbook all I have to do is run the playbook regularly to update the
dns records. This can easily be done with a cron job but I will be doing this
with Red Hat's ansible service called AWX. But that is for yet another future blog post...
