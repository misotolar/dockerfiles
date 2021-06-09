#!/bin/bash

set -e

PLUGIN_README="${PLUGIN_README:-README.md}"

if [[ -z "$PLUGIN_USERNAME" ]]; then
    printf "Docker Hub username not set.\n"
    exit 1
elif [[ -z "$PLUGIN_PASSWORD" ]]; then
    printf "Docker Hub password not set.\n"
    exit 1
elif [[ -z "$PLUGIN_REPO" ]]; then
    printf "Docker Hub repository not set.\n"
    exit 1
elif [[ ! -r "$PLUGIN_README" ]]; then
    printf "README not found\n."
    exit 1
fi

declare -r token=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"username": "'"$PLUGIN_USERNAME"'", "password": "'"$PLUGIN_PASSWORD"'"}' \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

if [[ "${token}" = "null" ]]; then
    printf "Unable to login to Docker Hub.\n"
    exit 1
fi

if [[ ! -z "$PLUGIN_DESC" ]]; then
    declare -r code1=$(jq -n --arg desc "$PLUGIN_DESC" \
        '{"registry":"registry-1.docker.io","description": $desc }' | \
            curl -s -o /dev/null  -L -w "%{http_code}" \
                https://hub.docker.com/v2/repositories/"$PLUGIN_REPO"/ \
                -d @- -X PATCH \
                -H "Content-Type: application/json" \
                -H "Authorization: JWT ${token}")

    if [[ "${code1}" = "200" ]]; then
        printf "Successfully pushed description to Docker Hub.\n"
    else
        printf "Unable to push description to Docker Hub, response code: %s\n" "${code1}"
        exit 1
    fi
fi

declare -r code2=$(jq -n --arg readme "$(<$PLUGIN_README)" \
    '{"registry":"registry-1.docker.io","full_description": $readme }' | \
        curl -s -o /dev/null  -L -w "%{http_code}" \
            https://hub.docker.com/v2/repositories/"$PLUGIN_REPO"/ \
            -d @- -X PATCH \
            -H "Content-Type: application/json" \
            -H "Authorization: JWT ${token}")

if [[ "${code2}" = "200" ]]; then
    printf "Successfully pushed README to Docker Hub.\n"
else
    printf "Unable to push README to Docker Hub, response code: %s\n" "${code2}"
    exit 1
fi

declare -r code=