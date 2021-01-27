---
title: "I Made a Nextcloud"
date: 2021-01-27T14:14:08-07:00
draft: true
---
## I want to break freeeee
I am always thinking about what technologies I depend on on a regular basis.
Email, calendar, contacts, iMessage, maps and many others! I feel like its a
constant goal of my life to diversify and simplify these dependencies and with
my regular love for free and open sources software I continually try to push
away from "the big companies" and move to companies built on F.O.S.S. Its not
that I dont like "the big companies", many of them are doing very cool things in
and out of the technology world! As a software engineer its just so much fun to
build these tools myself and the extra plus is many times I can continue to run
them after the big companies shut them down _cough google reader_.

## That one about Nextcloud
One of my latest projects I've felt like trying is hosting my own Nextcloud instance.
Nextcloud is like a combination of g-suite and dropbox but entirely open source
and new apps and features are being added all the time! There are even countries
that run self hosted nextcloud instances to manage their documents and
communication! I wanted to run nextcloud for a couple reasons:

1. I have some free credits with a cloud hosting provider called Linode
(go listen to the Jupiter Broadcasting Linux Unplugged podcast *wink wink nudge nudge*)
2. I hear about it everywhere
3. I wanted to see how close I could get to moving off of google and dropbox

## Requirements
The first step when starting a new project for me is thinking through
requirements, so here's what I came up with:

- Needs to use https
    This is a must have for any service I run. Using traefik (I'll get to that
    later) makes this so easy theres just no reason not to.
- Needs to have regular backups
    If im gonna use this for my files I want to be able to get to them fairly
    often. And for the amature hoster I am i would rather have ease of repair
    over high availability in this case because if it does go down it wont hurt
    me too bad
- Needs to have scalable and reliable storage
    Object storage was my goto here. With many object storage services you only
    pay for what you use and transfer and even at that what you pay per GB is
    regularly under $0.02. Also so many of these object storage services have
    crazy high uptime and storage resiliancy guaranties. Also if I really feel
    like it I can always add a vm to replicate my storage from one provider to
    another
- Needs to be relatively cheap to run
    If I'm gonna replace a hosted service I'm gonna want this to come out
    somewhere around even or let the features out-weigh the extra cost. In this
    case the features of all the extra apps and integrations help out and end up
    putting me around $12 a month!
