#!/bin/bash

set -e

SITE_NAME="$1"

if [ -z "$SITE_NAME" ]; then
    echo ""
    echo "Usage:"
    echo "  $0 <site-name>"
    echo ""
    echo "Example:"
    echo "  $0 customer1"
    echo ""
    exit 1
fi

read -p "Delete site '${SITE_NAME}'? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi
NAMESPACE="$SITE_NAME"

echo ""
echo "========================================"
echo "Deleting Site"
echo "========================================"
echo "Site      : ${SITE_NAME}"
echo "Namespace : ${NAMESPACE}"
echo ""

echo "[1/2] Removing Helm release..."

helm uninstall "${SITE_NAME}" -n "${NAMESPACE}" || true

echo "[2/2] Deleting namespace..."

kubectl delete namespace "${NAMESPACE}"

echo ""
echo "========================================"
echo "SUCCESS"
echo "========================================"
echo "Site deleted"
echo ""
