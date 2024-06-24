#!/bin/bash

# List of repositories to deploy
repositories=("rs-cart" "rs-user" "rs-catalogue" "rs-web" "rs-ratings" "rs-shipping" "rs-mongo" "rs-mysql" "rs-dispatch")

# Function to fetch latest tag for a repository
function fetch_latest_tag() {
    local repo=$1
    local latest_tag=$(curl -s "https://hub.docker.com/v2/repositories/securityanddevops/$repo/tags/" | jq -r '.results | .[].name' | sort -V | tail -n 1)
    echo "$latest_tag"
}

# Iterate over repositories
for repo in "${repositories[@]}"; do
    latest_tag=$(fetch_latest_tag "$repo")
    if [ -z "$latest_tag" ]; then
        echo "Failed to fetch latest tag for $repo"
        continue
    fi

    # Update values.yaml for the repository
    values_file="./values.yaml"
    if [ -f "$values_file" ]; then
        sed -i "s/version: .*/version: $latest_tag/" "$values_file"
        echo "Updated $values_file with the latest tag: $latest_tag"
    else
        echo "values.yaml file not found at $values_file"
        continue
    fi

    # Deploy with Helm
    chart_path="./"
    helm upgrade --namespace testing --install robot-shop "$chart_path" --values "$values_file"
done
