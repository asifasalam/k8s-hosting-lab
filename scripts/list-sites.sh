#!/bin/bash

printf "\n"
printf "%-20s %-20s %-30s\n" \
"SITE" \
"NAMESPACE" \
"HOST"

printf "%-20s %-20s %-30s\n" \
"----" \
"---------" \
"----"

kubectl get ingress -A \
-o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.spec.rules[0].host}{"\n"}{end}' |
while read NAMESPACE HOST
do
    printf "%-20s %-20s %-30s\n" \
    "$NAMESPACE" \
    "$NAMESPACE" \
    "$HOST"
done
