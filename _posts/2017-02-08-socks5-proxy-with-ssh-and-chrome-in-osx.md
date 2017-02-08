---
layout: post
title: SOCKS5 proxy with ssh tunnel and chrome in OSX
category: tutorials
technology: chrome
author: onnimonni
tags: ssh socks5 proxy chrome
last_modified_at: 2017-02-08 23:32:45 +0200
---

Today I learned how to debug http services with chrome in remote environment.

I needed to debug http2 services which were only available in remote environment.

Here are the commands that you need:
```bash
# Open socks5 proxy to local port 1337
# This connects to remote host using ssh into port 2222
$ ssh -D 1337 -f -C -q -N user@remote -p 2222

# Symlink chrome binary to PATH
# ( This is optional )
$ ln -s /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  /usr/local/bin/chrome

# Open chrome using the socks5 proxy in port 1337
$ chrome --proxy-server="socks5://127.0.0.1:1337" \
  --host-resolver-rules="MAP * 0.0.0.0 , EXCLUDE localhost"
```

After this new chrome window opens and all requests except `localhost` are resolved through the remote machine.

Now you can access remote services easily from your browser.
