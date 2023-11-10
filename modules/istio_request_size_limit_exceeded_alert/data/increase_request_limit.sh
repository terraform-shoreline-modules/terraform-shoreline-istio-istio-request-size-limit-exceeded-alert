#!/bin/bash

# Get the Istio deployment name
DEPLOYMENT=${ISTIO_DEPLOYMENT_NAME}

# Get the current Istio configuration
CURRENT_CONFIG=$(kubectl get deployment $DEPLOYMENT -o json)

# Increase the request size limit to 50MB
NEW_CONFIG=$(echo $CURRENT_CONFIG | jq '.spec.template.spec.containers[0].env += [{"name": "ISTIO_META_REQUESTED_NETWORK_VIEW", "value": "outbound", "name": "ISTIO_REQUESTED_NETWORK_VIEW", "value": "outbound", "name": "ISTIO_REQUESTED_NETWORK_VIEW_HTTP_MAX_REQUEST_HEADERS_KB", "value": "50000", "name": "ISTIO_REQUESTED_NETWORK_VIEW_HTTP_MAX_REQUEST_BODY_KB", "value": "50000"}]')

# Update the Istio deployment with the new configuration
kubectl apply -f <(echo $NEW_CONFIG) --record