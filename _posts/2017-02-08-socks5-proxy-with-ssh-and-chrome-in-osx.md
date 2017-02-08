---
layout: post
title: "Socks5 proxy with ssh and chrome in OSX"
category: tutorials
technology: chrome
author: onnimonni
tags: ssh socks5 chrome
date: 2017-02-08 23:26:33
---

Today I learned how to debug http services with chrome in remote environment.
I needed to debug http2 services which were only available in remote environment.

Here are the commands that you need:
```bash
# Open socks5 proxy to port 1337 and connect to remote host with port 2222
$ ssh -D 1337 -f -C -q -N user@remote -p 2222


# Symlink chrome binary to PATH
# ( This is optional )
$ ln -s /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome /usr/local/bin/chrome

# Open chrome using the socks5 proxy in port 1337
$ chrome --proxy-server="socks5://127.0.0.1:1337" --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost"
```

After this new chrome windown opens and all requests except `localhost` are resolved through the remote machine.