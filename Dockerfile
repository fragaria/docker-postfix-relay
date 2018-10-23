FROM alpine:3.4

MAINTAINER Filip Varecha <filip.varecha@fragaria.cz>

RUN apk add --no-cache postfix ca-certificates rsyslog supervisor \
    && /usr/bin/newaliases

COPY . /

EXPOSE 25

ENTRYPOINT [ "/relay.sh" ]
