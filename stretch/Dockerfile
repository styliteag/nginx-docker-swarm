FROM nginx
LABEL maintainer="Wim Bonis wb@stylite.de"

RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    bind9-host curl \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

ADD entrypoint.sh /

ADD upstream.tmpl /

# Set to the Host nginx should monitor in DNS
ENV UPSTREAM tasks.upstream
ENV TEMPLATE_IN /upstream.tmpl
ENV TEMPLATE_OUT /etc/nginx/upstream.inc

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx","-g","'daemon off;'"]
