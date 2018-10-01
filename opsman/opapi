#!/usr/bin/env bash

set -e

function guard_clause {
    fail_script=false

    [ -z "$1" ] && { echo "Missing: Provide OPSMAN_DOMAIN"; fail_script=true; }
    [ -z "$2" ] && { echo "Missing: Provide OPSMAN_USER"; fail_script=true; }
    [ -z "$3" ] && { echo "Missing: Provide OPSMAN_PASS"; fail_script=true; }

    if $fail_script; then
        exit 1;
    fi
}

echo "OPsman API"

case "$1" in
    auth)
        guard_clause "$OPSMAN_DOMAIN" "$OPSMAN_USER" "$OPSMAN_PASS"

        echo "Authenticating against $OPSMAN_DOMAIN domain with user $OPSMAN_USER"
        curl -s -k -H "Accept: application/json;charset=utf-8" -d "grant_type=password" -d "username=$OPSMAN_USER" -d "password=$OPSMAN_PASS" -u 'opsman:' https://$OPSMAN_DOMAIN/uaa/oauth/token | jq
        ;;
    *)
        echo "Usage Instructions:"
        echo " > ./opapi auth"
        exit 0
        ;;
esac

exit 0;


