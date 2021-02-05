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

## Installation
Ok so lets actually get to what you all came here for "how to install". Heres
the steps:

1. Start up a new vm on your favorite hosting service (I used linode). I chose
   literally the cheapest vm they had! 1GB of ram and 1 cpu core and ubuntu
   20.04.
   - Yes its a little slow but for me this works and with backups I can always restore to a larger instance relatively easily if needed.
   - Important node: please set a heavily strong password here for the vm that you generate and store in the password manager that you most definately use...
   - Another important note: add your ssh key to the vm in the setup wizard, please avoid using ssh password based auth
2. Login, run updates and lock this thing down
   - I use ansible to run a set of playbooks to better lockdown any vms I create
     and one of my favorite roles to run is geerlingguy.security. It disables
     password auth, root ssh, and installs fail2ban. I highly recommend either
     using this role or doing at least this much to secure ssh
   - I also recommend doing some kind of firewall. Linode is in beta for their
     firewalls right now but also setting up a firewall on the vm with `ufw`
     (uncomplicated firewall) is easy and there are many tutorials online for
     this
3. Setup your dns provider to point your domain `nextcloud.example.com` at the
   ip of your new vm, having this already setup will make setting up https much
   easier.
4. Install docker with `sudo apt install docker.io`
    - Make sure docker is always started with the system with `sudo systemctl
      enable docker`
    - Start the docker daemon `sudo systemctl start docker`
    - Create a docker group and add yourself to it `sudo groupadd docker` and `sudo usermod -aG docker $USER`
    - Restart your vm to make sure your user is in the new docker group `sudo
      restart`
5. Setup nextcloud with `docker-compose`. Heres my docker-compose.yaml

```
version: "3.8"
services:
  traefik:
    image: traefik
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    labels:
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=http"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
    volumes:
      - "/etc/timezone:/etc/timezone:ro"
      - "/etc/localtime:/etc/localtime:ro"
      - "~/config/traefik:/etc/traefik"
      - "/var/run/docker.sock:/var/run/docker.sock"
  db:
    image: mariadb
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD={{ nextcloud_mysql_password }}
      - MYSQL_PASSWORD={{ nextcloud_mysql_password }}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  app:
    image: nextcloud:latest
    restart: always
    volumes:
      - nextcloud:/var/www/html
    labels:
      - traefik.enable=true
      - traefik.http.routers.app.rule=Host(`nextcloud.example.com`)
      - traefik.http.routers.app.tls.certresolver=webresolver
      - traefik.http.routers.app.entrypoints=websecure
      - "traefik.http.routers.app.middlewares=nc-rep,nc-header"
      - "traefik.http.middlewares.nc-rep.redirectregex.regex=https://(.*)/.well-known/(card|cal)dav"
      - "traefik.http.middlewares.nc-rep.redirectregex.replacement=https://$$1/remote.php/dav/"
      - "traefik.http.middlewares.nc-rep.redirectregex.permanent=true"
      - "traefik.http.middlewares.nc-header.headers.frameDeny=true"
      - "traefik.http.middlewares.nc-header.headers.sslRedirect=true"
      - "traefik.http.middlewares.nc-header.headers.contentTypeNosniff=true"
      - "traefik.http.middlewares.nc-header.headers.stsIncludeSubdomains=true"
      - "traefik.http.middlewares.nc-header.headers.stsPreload=true"
      - "traefik.http.middlewares.nc-header.headers.stsSeconds=31536000"
      - "traefik.http.middlewares.nc-header.headers.referrerPolicy=no-referrer"
      - "traefik.http.middlewares.nc-header.headers.browserXssFilter=true"
      - "traefik.http.middlewares.nc-header.headers.customRequestHeaders.X-Forwarded-Proto=https"
      - "traefik.http.middlewares.nc-header.headers.customResponseHeaders.X-Robots-Tag=none"
      - "traefik.http.middlewares.nc-header.headers.customFrameOptionsValue=SAMEORIGIN"
    environment:
      - MYSQL_PASSWORD={{ nextcloud_mysql_password }}
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=db
volumes:
  nextcloud:
  db:
```

Couple Notes here:
- I put this file in `~/containers` for organization (`mkdir ~/containers`)
- I'm using traefik as my https proxy, its the easiest way I know to get lets
  encrypt https certs and yes you should be using nextcloud with https if you
  are accessing this across the internet.
- That entry for mariadb is directly from the docker hub page for nextcloud
- Everywhere you see `{{ nextcloud_mysql_password }}` replace it with your own
  massive generated password that you also keep in your password manager ;) I
  use this file in ansible and it automagically replaces this for me.
- This assumes you have a directory in your home directory called
  ~/config/traefik (`mkdir -p ~/config/traefik`) and in that directory there needs to be a traefik.yaml,
  heres mine for reference, make sure to replace `{{ email }}` with your email ;):

```
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false

certificatesResolvers:
  webresolver:
    acme:
      email: "{{ email }}"
      storage: "/etc/traefik/acme.json"
      httpChallenge:
        entryPoint: "web"
```

6. `cd ~/containers; docker-compose up -d` and wait! Because we have a tiny
   little vm the initial startup can be a little slow... but before you know it
   you should be ready to go to `https://nextcloud.example.com` and create a new
   admin account and login!
   - When I first tried to create an admin account I got errors about not being
     able to connect to the mysql server, for some reason the first time my db
     came up it failed to get setup correctly... The solution?
     1. `docker-compose stop db` stop the db container
     2. `docker-compose rm db` remove the db container
     3. `docker volume ls` and find the volume for the db (most likely ending in
        `_db`)
     4. `docker volume rm {{ db_volume_name }}` delete the db data
     5. `docker-compose up -d db` start the db back up again, after waiting a
        couple minutes refresh your nextcloud page and you should be good to go

And now you have a working and running nextcloud instance!!

## Adding Storage
