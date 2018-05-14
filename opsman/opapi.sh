#!/usr/bin/env bash

echo "OPsman API"

case "$1" in 
    auth)
        echo "Authenticating against $OPSMAN_DOMAIN"
        curl -s -k -H "Accept: application/json;charset=utf-8" -d "grant_type=password" -d "username=$OPSMAN_USER" -d "password=$OPSMAN_PASS" -u 'opsman:' https://$OPSMAN_DOMAIN/uaa/oauth/token | jq
        ;;
    *) 
        echo "Nothing to do"
        exit 0
        ;;
esac

exit 0;
