#!/bin/bash
set -eu
DOMAIN="srt"
TLD=${1}
OM_USER=${2}
OM_PASS=${3}

om () {
  command om -t https://opsman.$TLD -u $OM_USER -p $OM_PASS -k "$@"
}

CF_GUID=$(om curl -s -p /api/v0/deployed/products | jq -r '.[] | select(.type == "cf") | .guid')
ADMIN_CLIENT_CREDS_JSON=$(om curl -s -p /api/v0/deployed/products/$CF_GUID/credentials/.uaa.admin_client_credentials)
ADMIN_CLIENT_IDENTITY=$(echo $ADMIN_CLIENT_CREDS_JSON | jq -r '.credential.value.identity')
ADMIN_CLIENT_PASSWORD=$(echo $ADMIN_CLIENT_CREDS_JSON | jq -r '.credential.value.password')

uaac target uaa.sys.$DOMAIN.$TLD --skip-ssl-validation
uaac token client get $ADMIN_CLIENT_IDENTITY -s $ADMIN_CLIENT_PASSWORD

# ## LOCAL - create ertadmin
uaac user add ertadmin -p pivotal01 --emails ertadmin@$DOMAIN.$TLD
uaac member add cloud_controller.admin ertadmin
uaac member add uaa.admin ertadmin
uaac member add scim.read ertadmin
uaac member add scim.write ertadmin
uaac member add zones.read ertadmin
uaac member add zones.write ertadmin
uaac member add doppler.firehose ertadmin

# use ertadmin to create org, space, developer
CF_USER="mcnichol"
CF_PASS="pivotal01"
CF_ORG="demo"
CF_SPACE="dev"

cf api api.sys.$DOMAIN.$TLD --skip-ssl-validation
cf login -u ertadmin -p $CF_PASS -o system -s system
cf create-org $CF_ORG
cf create-space $CF_SPACE -o $CF_ORG

cf create-user $CF_USER $CF_PASS

cf set-space-role $CF_USER $CF_ORG $CF_SPACE SpaceDeveloper
cf logout

# # TODO: use uaausersimport to bulk import multiple users
# #https://github.com/pivotalservices/uaausersimport/blob/master/README.md
#
# # add a god client for ert uaa
# uaac client add god --no-interactive -s Pivotal1y \
#   --clone admin \
#   --authorities "clients.read clients.secret clients.write cloud_controller.admin password.write scim.read scim.write scim.zones uaa.admin uaa.resource zones.read zones.write"
#
# # add a backup client for opsman uaa
# uaac target https://opsman.cfscale.$TLD/uaa --skip-ssl-validation
# uaac token owner get opsman omadmin -s "" -p Pivotal1y
# uaac client add ombackup --no-interactive -s Pivotal1y \
#   --name ombackup \
#   --scope "opsman.admin" \
#   --authorized_grant_types client_credentials \
#   --authorities "opsman.admin" \
#   --access_token_validity 43200 \
#   --refresh_token_validity 43200
