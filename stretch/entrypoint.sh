#!/bin/bash
set -e

echo "Starting $0 on $HOSTNAME"

if [ -e /version.txt ] ; then
  echo "Version:"
  cat /version.txt
fi

echo "UPSTREAM: $UPSTREAM"
echo "TEMPLATE: $TEMPLATE_IN -> $TEMPLATE_OUT"

# Make a file with the dns of the upstream
IP=$UPSTREAM envsubst < $TEMPLATE_IN > $TEMPLATE_OUT

(
  function generate_config {
	  IPS="$*"
	  echo "generate_config $IPS"
	  > $TEMPLATE_OUT
	  for ip in $IPS ; do
		  echo "Doing $ip"
		  IP=$ip envsubst < $TEMPLATE_IN >> $TEMPLATE_OUT
          done
	  # If it fails go back to default
	  if ! nginx -t ; then
		echo "FAILED.. go back"
	  	IP=$UPSTREAM envsubst < $TEMPLATE_IN > $TEMPLATE_OUT
	  fi
  }
  UPSTREAM_OLD=none
  while : 
  do
    UPSTREAM_IPS=$(host -t a -4 $UPSTREAM | cut -d " " -f 4 | sort -u)
    if [ "$UPSTREAM_OLD" != "$UPSTREAM_IPS" ] ; then
	 echo "=========OLD==============="
	 echo $UPSTREAM_OLD
	 echo "=========NEW==============="
	 echo $UPSTREAM_IPS
	 generate_config $UPSTREAM_IPS
	 echo "==========================="
	 echo "== Reloading NGINX      ==="
	 echo "==========================="
         UPSTREAM_OLD=$UPSTREAM_IPS
         nginx -s reload
    fi
    sleep 60
  done
) &

# The default is command:"nginx -g 'daemon off;'"
while : ; do
  echo "@: $@"
  nginx -t
  eval "$@"
  sleep 10
done
# This should never be reached
exec "$@"
