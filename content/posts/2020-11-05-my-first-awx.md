---
title: My First Awx
date: 2020-11-05
---

I'm a little bit of an ansible fan boy. But for good reason! Ansible is a
fantastic way to provision, deploy and update machines and applications. It can
do just about anything you can think of and it make one thing very easy,
"gitops".

My background and career is as a software developer and CI/CD practices and
their huge benefits are engrained in me and so the idea that I could describe my
home infrastructure as code and then "auto deploy" that code after its pushed up
just rings so true with me. Ever since I started using ansible with my first
home server I have been wanting to setup a CD process for my ansible playbooks,
for a while I had a jenkins server setup to do just this but it just wasn't
great. Jenkins has very minimal ansible support and what it has is very raw.
It feels a lot like I am just concatenating commands together and has no support
for anything fun like dynamic inventories and such. After doing a little more
research I found a tool called Ansible Tower. Tower is an enterprise tool made
by Red Hat themselves to run ansible and the best part is it has an upstream
open source version called AWX and once I found this I knew I was in love. AWX
is able to dynamically pull inventories from places like aws and azure or even a
git repo and if its not builtin you can write scripts to pull inventories
yourself. It securely stores credentials and can automagically inject them into
jobs. You can create templates for jobs that ask questions to fill variables for
ansible. I could list off hundreds of amazing things that AWX does but if you're
at all interested [go check it out for yourself](https://www.ansible.com/products/tower).

AWX has some decent system requirements so I decided my best chance was to
create a new vm. I built a quick playbook to to run some default roles I like to
run (`oefenweb.dns`, `geerlingguy.github-users`, `geerlingguy.ntp`,
`geerlingguy.security`) and then ssh'd into the vm and followed the awx install
instructions for docker-compose [here](https://github.com/ansible/awx/blob/devel/INSTALL.md).
It took a little bit to pull and build docker containers and such but it worked
first try and I navigated to port 80 on my awx vm and I was up and running!

The first task I wanted AWX to do was just a simple hourly `ping:` to all my
vms. I created a new project that pointed to
[my infrastructure git repo](https://github.com/kevindurb/infra). Added a new
inventory that pulled from my inventory file in the same repo. Setup a new
"machine" credential with an ssh key and lastly created a template to pull all
of these together and added a hourly schedule and boom I was up and running!
Adding a job to run another playbook that deploys my vm for docker containers
was even easier with all the inventory and credentials in place.

Now that I have a central place to run my ansible playbooks it is even easier to
add to my home infrastructure. Overall I'm super impressed by AWX and its
flexibility and power. Stay tuned I have even more fun planned for my home
infrastructure (pst I'm gonna be setting up a wireguard vpn so I dont have to
port forward and use dynamic dns anymore).I also have another project I've been
slowly putting together that is pushing my electronics and embedded programming
skillz. But that is for yet another future blog post...
