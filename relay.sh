#!/bin/sh

RELAY_HOST=${RELAY_HOST?Missing env var RELAY_HOST}
RELAY_MYHOSTNAME=${RELAY_MYHOSTNAME?Missing env var RELAY_MYHOSTNAME}
RELAY_USERNAME=${RELAY_USERNAME?Missing env var RELAY_USERNAME}
RELAY_PASSWORD=${RELAY_PASSWORD?Missing env var RELAY_PASSWORD}
RELAY_SECURITY_OPTIONS=${RELAY_SECURITY_OPTIONS:-noanonymous}
RELAY_TLS_ENABLED=${RELAY_TLS_ENABLED:-yes}
RELAY_TLS_SECURITY_LEVEL=${RELAY_TLS_SECURITY_LEVEL:-encrypt}
RELAY_TLS_STARTTLS_OFFER=${RELAY_TLS_STARTTLS_OFFER:-yes}

# handle sasl
echo "${RELAY_HOST} ${RELAY_USERNAME}:${RELAY_PASSWORD}" > /etc/postfix/sasl_passwd || exit 1
postmap /etc/postfix/sasl_passwd || exit 1
rm /etc/postfix/sasl_passwd || exit 1

postconf 'smtp_sasl_auth_enable = yes' || exit 1
postconf 'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd' || exit 1
postconf "smtp_sasl_security_options = ${RELAY_SECURITY_OPTIONS}" || exit 1

# TLS-related settings.
postconf "smtp_use_tls = ${RELAY_TLS_ENABLED}" || exit 1
postconf "smtp_tls_security_level = ${RELAY_TLS_SECURITY_LEVEL}" || exit 1
postconf "smtp_tls_note_starttls_offer = ${RELAY_TLS_STARTTLS_OFFER}" || exit 1
postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt'

# These are required.
postconf "relayhost = ${RELAY_HOST}" || exit 1
postconf "myhostname = ${RELAY_MYHOSTNAME}" || exit 1

# Override what you want here. The 10. network is for kubernetes
postconf 'mynetworks = ${RELAY_NETWORS:-10.0.0.0/8,127.0.0.0/8,172.17.0.0/16}' || exit 1

# http://www.postfix.org/COMPATIBILITY_README.html#smtputf8_enable
postconf 'smtputf8_enable = no' || exit 1

# This makes sure the message id is set. If this is set to no dkim=fail will happen.
postconf 'always_add_missing_headers = yes' || exit 1

/usr/bin/supervisord -n
