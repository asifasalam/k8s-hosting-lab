#!/bin/bash

set -e

SITE_NAME="$1"
DOMAIN="$2"
IMAGE="${3:-nginx}"
PLAN="${4:-bronze}"

if [ -z "$SITE_NAME" ] || [ -z "$DOMAIN" ]; then
    echo ""
    echo "Usage:"
    echo "  $0 <site-name> <domain> [image] [plan]"
    echo ""
    echo "Example:"
    echo "  $0 customer1 customer1.local nginx bronze"
    echo ""
    exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

PLAN_FILE="${PROJECT_ROOT}/plans/${PLAN}.yaml"
QUOTA_TEMPLATE="${PROJECT_ROOT}/templates/quota.yaml"

if [ ! -f "$PLAN_FILE" ]; then
    echo "ERROR: Plan '${PLAN}' does not exist."
    exit 1
fi

echo ""
echo "========================================"
echo "Creating Site"
echo "========================================"
echo "Site      : ${SITE_NAME}"
echo "Domain    : ${DOMAIN}"
echo "Image     : ${IMAGE}"
echo "Plan      : ${PLAN}"
echo ""

NAMESPACE="${SITE_NAME}"

echo "[1/4] Creating namespace..."

kubectl create namespace "${NAMESPACE}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "[2/4] Loading plan..."

source <(
    sed 's/: /=/' "$PLAN_FILE"
)

echo "[3/4] Applying quota..."

sed \
  -e "s/__NAMESPACE__/${NAMESPACE}/g" \
  -e "s/__PODS__/${pods}/g" \
  -e "s/__REQUESTS_CPU__/${requestsCpu}/g" \
  -e "s/__REQUESTS_MEMORY__/${requestsMemory}/g" \
  -e "s/__LIMITS_CPU__/${limitsCpu}/g" \
  -e "s/__LIMITS_MEMORY__/${limitsMemory}/g" \
  "$QUOTA_TEMPLATE" | kubectl apply -f -

echo "[4/4] Installing Helm chart..."

helm upgrade --install "${SITE_NAME}" \
  "${PROJECT_ROOT}/charts/website" \
  -n "${NAMESPACE}" \
  --set siteName="${SITE_NAME}" \
  --set host="${DOMAIN}" \
  --set image="${IMAGE}"

echo ""
echo "========================================"
echo "SUCCESS"
echo "========================================"
echo "Namespace : ${NAMESPACE}"
echo "Domain    : ${DOMAIN}"
echo "Plan      : ${PLAN}"
echo ""
echo "Check:"
echo "kubectl get all -n ${NAMESPACE}"
echo ""
