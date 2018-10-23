# postfix-relay

Simple postfix-based SMTP relay that runs in a Docker container.

Inspired by [applariat/kubernetes-postfix-relay-host](https://github.com/applariat/kubernetes-postfix-relay-host) and
adjusted for Amazon SES support.

## Overview

This repository contains docker image to easily set up a SMTP relay for services such as Amazon SES.


## Quickstart

Run using Docker.

```
docker run --rm -it -p 2525:25 \
	-e RELAY_HOST="[smtp.sendgrid.net]:587" \
	-e RELAY_MYHOSTNAME=relay.yourhost.com \
	-e RELAY_USERNAME=username \
	-e RELAY_PASSWORD=password \
	fragaria/postfix-relay

```
Send a test message
    $ telnet localhost 2525
    220 tx-smtp-relay.yourhost.com ESMTP Postfix

    helo localhost
    250 relay.yourhost.com

    mail from: noreply@yourhost.com
    250 2.1.0 Ok

    rcpt to: test@example.com<
    250 2.1.5 Ok

    data
    354 End data with <CR><LF>.<CR><LF>
    Subject: What?
    My hovercraft is full of eels.
    .
    250 2.0.0 Ok: queued as 982FF53C

    quit
    221 2.0.0 Bye
    Connection closed by foreign host
