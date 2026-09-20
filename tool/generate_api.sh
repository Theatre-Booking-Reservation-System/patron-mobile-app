#!/usr/bin/env sh
set -eu

openapi-generator-cli generate \
  -i openapi/patron-api.yaml \
  -g dart-dio \
  -o packages/sapumal_api \
  --additional-properties=pubName=sapumal_api,serializationLibrary=json_serializable
