#!/usr/bin/env bash

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage Instructions: ./pull-tag-push.sh [docker-registry]/[docker-project]"
  echo ""
  echo "e.g. ./pull-tag-push.sh harbor.pks.cfrocket.com/workshop"
  exit 1;
fi


HARBOR_REGISTRY="$(cut -d/ -f1 <<< "$1")"
HARBOR_PROJECT="$(cut -d/ -f2 <<< "$1")"

GUNA_DOCKERHUB="gvijayar"

ES_INIT_LATEST="es-init:latest"
HARBOR_GEOSEARCH_LATEST="harbor-geosearch:4.0"
HARBOR_ELASTICSEARCH_LATEST="harbor-elasticsearch:1.0"

echo "Pushing to Harbor Registry \`$HARBOR_REGISTRY\` at project \`$HARBOR_PROJECT\`"

for dockerImage in $ES_INIT_LATEST $HARBOR_ELASTICSEARCH_LATEST $HARBOR_GEOSEARCH_LATEST; do
  docker pull $GUNA_DOCKERHUB/$dockerImage
done

for dockerImage in $ES_INIT_LATEST $HARBOR_ELASTICSEARCH_LATEST $HARBOR_GEOSEARCH_LATEST; do
  docker tag $GUNA_DOCKERHUB/$dockerImage $HARBOR_REGISTRY/$HARBOR_PROJECT/$dockerImage
done

for dockerImage in $ES_INIT_LATEST $HARBOR_ELASTICSEARCH_LATEST $HARBOR_GEOSEARCH_LATEST; do
  docker push $HARBOR_REGISTRY/$HARBOR_PROJECT/$dockerImage
done

