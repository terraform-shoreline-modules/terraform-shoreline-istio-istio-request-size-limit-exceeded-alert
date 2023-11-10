
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Istio Request Size Limit Exceeded Alert

This incident type occurs when requests sent through the Istio service mesh exceed the configured size limits. This can cause service disruptions or failures, as the system is unable to process the oversized requests. An alert is triggered to notify the relevant stakeholders to investigate and resolve the issue in a timely manner.

### Parameters

```shell
export NAMESPACE="PLACEHOLDER"
export POD="PLACEHOLDER"
export SERVICE="PLACEHOLDER"
export ISTIO_DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### Check the status of the Istio control plane

```shell
kubectl get pods -n istio-system
```

### Check the status of the ingress gateway

```shell
kubectl get pods -n ${NAMESPACE}
```

### Check the Istio configuration for the namespace

```shell
kubectl get cm istio -n ${NAMESPACE} -o yaml
```

### Check the Istio configuration for the ingress gateway

```shell
kubectl get gateway -n ${NAMESPACE}
```

### Check the Istio virtual service configuration for the service

```shell
kubectl get vs -n ${NAMESPACE}
```

### Check the Istio destination rule configuration for the service

```shell
kubectl get dr -n ${NAMESPACE}
```

### Check the Envoy proxy configuration for the service

```shell
kubectl exec ${POD} -c istio-proxy -n ${NAMESPACE} -- pilot-agent request GET configuration_dump | grep ${SERVICE}
```

### Check the Envoy proxy access logs for requests that exceeded the limit

```shell
kubectl logs ${POD} -c istio-proxy -n ${NAMESPACE} | grep ${SERVICE} | grep "exceeded maximum allowed size"
```

### Check the request size limit in the Istio virtual service configuration for the service

```shell
kubectl get vs -n ${NAMESPACE} -o yaml | grep maxBytes
```

### Check the request size limit in the Istio destination rule configuration for the service

```shell
kubectl get dr -n ${NAMESPACE} -o yaml | grep maxBytes
```

## Repair

### Increase the configured size limit for requests in Istio configuration.

```shell
#!/bin/bash

# Get the Istio deployment name
DEPLOYMENT=${ISTIO_DEPLOYMENT_NAME}

# Get the current Istio configuration
CURRENT_CONFIG=$(kubectl get deployment $DEPLOYMENT -o json)

# Increase the request size limit to 50MB
NEW_CONFIG=$(echo $CURRENT_CONFIG | jq '.spec.template.spec.containers[0].env += [{"name": "ISTIO_META_REQUESTED_NETWORK_VIEW", "value": "outbound", "name": "ISTIO_REQUESTED_NETWORK_VIEW", "value": "outbound", "name": "ISTIO_REQUESTED_NETWORK_VIEW_HTTP_MAX_REQUEST_HEADERS_KB", "value": "50000", "name": "ISTIO_REQUESTED_NETWORK_VIEW_HTTP_MAX_REQUEST_BODY_KB", "value": "50000"}]')

# Update the Istio deployment with the new configuration
kubectl apply -f <(echo $NEW_CONFIG) --record
```