#!/bin/bash
set -e
set -x

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
	  nginx -t && IP=$UPSTREAM envsubst < $TEMPLATE_IN > $TEMPLATE_OUT
	  nginx -t
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
  /bin/bash -c "$@"
  #eval "$@"
  sleep 10
done
# This should never be reached
exec "$@"
