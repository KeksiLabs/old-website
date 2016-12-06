---
layout: post
title: "How to manage remote server users with ansible"
categories: tutorials
tags: ansible
author: Onni Hakala
---

This post shows an powerful example of how to do user access management for admin/developer user accounts for medium to big sized web agencies. Managing users efficiently and securely in big company usually includes a clunky process like LDAP. Today I will show you how to use git and ansible instead.

## Introduction

When companies grow and start to have tens or hundreds of servers it starts to take enormous amount of time to create users into the servers manually. Many web agencies just get tired and allow `root` user access for all of their administrators/developers.

This is a bad practise which should be always avoided because it makes auditing so much harder. What about if a person leaves the company or their laptop and private ssh keys get stolen? Then you would need to revoke the access ASAP and this will be harder if the company doesn't keep record of all of their users and their access levels.

Many developers also won't understand how dangerous it is to paste the same root user passwords in plaintext in sms, email or company chat like slack. It's quite easy to gain access to any of those medias.

## Ansible and ssh keys to the rescue

We in Keksi Labs have helped multiple smaller companies to manage this problem with configuration management.

The solution is to keep record of all of the granted users in git and use ansible to deploy all of the changes.

This is passwordless solution for remote server access with ssh.

If you want to see full real world example look into our github:

[KeksiLabs/ansible-user-management-example](https://github.com/KeksiLabs/ansible-user-management-example).

### Tutorial for ansible and git

Here's quick example for how to do this with ansible. More advanced users should see the provided repository mentioned earlier.

### Step 1. Create a project
```console
mkdir user-management-ansible
cd user-management-ansible
git init .
```

### Step 2: Copy example ansible into your project

Copy this provided `yml` ansbile config into file named `users.yml`.

Let's see what this does:

* It creates new group called `infra_admin` and gives it sudo privileges.
* It checks that provided users exist in the target machines with their ssh keys
* It deletes users which should be absent

```yml {% raw %}
##
# This ansible playbook handles and creates all provided users from
# company_admin_list
#
# For more advanced but similiar setup see: https://github.com/KeksiLabs/ansible-user-management-example
##
---
- name: Install all users
  hosts: all
  become: true
  vars:
    admin_group: 'infra_admin'
    company_admin_list:
      # This is how add users to servers
      - name: "Onni Hakala"
        username: "onnimonni"
        keys:
          active:
            - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8gOdvYe12yaVQGMZXgn0qcd7vxMZhj1wsBTDFP/HnwdnbywbV/jt//yGex51cTkfqoP3YlkdgUfQeKJws4j7rxu04gx6uRBIlRcR+7wdcFgksFs4EFumTpZOSOwKybHVIbeIubLi76+mhB9L2JXD4f+TtkL0WJtvBDsCavGLHbru2JafS3K/6b97sU2vpmA/mDREKDpnuVxcMXsXlY0THgoxx70L7SjYsWMzRYiJc+FWzMqyi1yribhEUuUT4ch6B7DiBuPfWFQUlA2KkGbihsw+Kmyrw0e36z1MOEWAhroczt8zKjawWeYQ4qTwQRrjM8b+C2yfFgBpUqFAhAM0Lb9dh8V3xfui30zik2eW2LTQ4JtD2xNUflA+NvG2+fcB7w3ub+QNXI3zp+Joto627oB3j4Nao+s/XHOd0T8idHVrbfhoRK8UE4r6nKI8b5b7JrzaDipE1CjS2TsIixaj9a/VxYMtNE2A9JPGHsXlIPpi++GaW+rz4DZoqkArfsFE= onni@keksi.io"
          disabled:
            - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsPoDM21LjBodcS3Kiq7ZDyNjFY4L03Yx2nSoSzdV7TKj00Zk8gh1hSSgI/xSDXiK+QEbfPuh/7+G3sfeDDNavjWUA1kdLve4D6MTI302C3HilK6wOZV67ezyAgdgf/VCHfx+no+bocw/05r1VamLrnFjDasWAQFFeFLaOnfQTArHQRl2Z8+4ZtZ1YQPhnleFQfEz546D3oWE1DS3vuXL1Qodz3gijtHhGnc3jaQM+7m/gg2vrcL6bc/vCtdunpA1fSQrBSx0kK4qdTWwc2LZDwKIT3YP5GthvgkFHsbCo2mNdBwWZfOBTYr5LBpz9YBcO7oVBWVEI00BdEPRFOYJL onnimonni@Onni-MacBook-Air.local"
        shell: "/bin/bash"
        state: present
      # This is how you remove users
      - name: "Example Quitted Person"
        username: "example-quitted-person"
        state: absent

  tasks:

  - name: Setup all users
    user:
      name: "{{ item.username }}"
      state: "{{ item.state | default('present') }}"
      shell: "{{ item.shell | default('/bin/bash') }}"
      group: "{{ admin_group }}"
      remove: yes
    when: item.username is defined
    with_items:
      - "{{ full_admin_list }}"

  - name: Add SSH-keys to users
    authorized_key:
      user: "{{ item.0.username }}"
      key: "{{ item.1 }}"
    with_subelements:
      - "{{ full_admin_list }}"
      - keys.active
      - flags:
        skip_missing: True
    when: item.0.state != "absent"

  - name: Remove old SSH-keys from users
    authorized_key:
      user: "{{ item.0.username }}"
      key: "{{ item.1 }}"
      state: absent
    with_subelements:
      - "{{ full_admin_list }}"
      - keys.disabled
      - flags:
        skip_missing: True
    when: item.0.state != "absent"

  - name: Add admin group to sudoers
    lineinfile: dest=/etc/sudoers regexp="^%{{ admin_group }}" line="%{{ admin_group }} ALL=(ALL) NOPASSWD:ALL"

  - name: Disable Requiretty from sudoers
    lineinfile: dest=/etc/sudoers regexp="Defaults    requiretty" line="#Defaults    requiretty"
{% endraw %}```

### Step 3: Add your users

Edit this section from the provided example and add your username and ssh keys. You don't have to have any disabled keys when you start.

```yaml
company_admin_list:
  # This is how add users to servers
  - name: "Onni Hakala"
    username: "onnimonni"
    keys:
      active:
        - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8gOdvYe12yaVQGMZXgn0qcd7vxMZhj1wsBTDFP/HnwdnbywbV/jt//yGex51cTkfqoP3YlkdgUfQeKJws4j7rxu04gx6uRBIlRcR+7wdcFgksFs4EFumTpZOSOwKybHVIbeIubLi76+mhB9L2JXD4f+TtkL0WJtvBDsCavGLHbru2JafS3K/6b97sU2vpmA/mDREKDpnuVxcMXsXlY0THgoxx70L7SjYsWMzRYiJc+FWzMqyi1yribhEUuUT4ch6B7DiBuPfWFQUlA2KkGbihsw+Kmyrw0e36z1MOEWAhroczt8zKjawWeYQ4qTwQRrjM8b+C2yfFgBpUqFAhAM0Lb9dh8V3xfui30zik2eW2LTQ4JtD2xNUflA+NvG2+fcB7w3ub+QNXI3zp+Joto627oB3j4Nao+s/XHOd0T8idHVrbfhoRK8UE4r6nKI8b5b7JrzaDipE1CjS2TsIixaj9a/VxYMtNE2A9JPGHsXlIPpi++GaW+rz4DZoqkArfsFE= onni@keksi.io"
      disabled:
        - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsPoDM21LjBodcS3Kiq7ZDyNjFY4L03Yx2nSoSzdV7TKj00Zk8gh1hSSgI/xSDXiK+QEbfPuh/7+G3sfeDDNavjWUA1kdLve4D6MTI302C3HilK6wOZV67ezyAgdgf/VCHfx+no+bocw/05r1VamLrnFjDasWAQFFeFLaOnfQTArHQRl2Z8+4ZtZ1YQPhnleFQfEz546D3oWE1DS3vuXL1Qodz3gijtHhGnc3jaQM+7m/gg2vrcL6bc/vCtdunpA1fSQrBSx0kK4qdTWwc2LZDwKIT3YP5GthvgkFHsbCo2mNdBwWZfOBTYr5LBpz9YBcO7oVBWVEI00BdEPRFOYJL onnimonni@Onni-MacBook-Air.local"
    shell: "/bin/bash"
    state: present
  # This is how you remove users
  - name: "Example Quitted Person"
    username: "example-quitted-person"
    state: absent
```

### Step 4: Add your servers
Create file called `inventory` with your servers in it:

Remember to use real IP addresses or hostnames instead of `xxx.xxx.xxx.xxx` or `yyy.yyy.yyy.yyy`.

```
[servers]
xxx.xxx.xxx.xxx ansible_port=22
yyy.yyy.yyy.yyy ansible_port=22
```

You can use a custom ssh port by providing `ansible_port` variable.


### Step 5: Install ansible

For OSX ansible can be installed with homebrew:

```console
$ brew install ansible
```

Usually you want to use pip because it provides better version handling:

```console
$ pip install ansible
```

### Step 6: Deploy your users

You can use any user which is already setupped in the servers. When starting with the new servers it's usually `root`.

This deploys all provided users with ansible:

```console
$ ansible-playbook -i inventory users.yml -u root --ask-pass
```

### Step 7: Test ssh login
Now try to login with the users that you created. Everything should just work.

### Step 8: Store your changes in git

Now commit all your changes:

```console
$ git add --all
$ git commit -am "Initial user setup"
```

### Step 9: Push these configs in private git repository

It's usually a good idea to share this setup with your workmates.

We recommend Github, Gitlab and Bitbucket. This repository doesn't contain anything sensitive like plaintext passwords so It's okay to put it into 3rd party version control.

## Congratulations

You are now managing all of your users with ansible. When you need to have more users just add them into the users array and deploy again. Remember to share your changes with your coworkers and teach them how to use this setup.

If you want to learn more you should head into our example repo: [KeksiLabs/ansible-user-management-example](https://github.com/KeksiLabs/ansible-user-management-example).

