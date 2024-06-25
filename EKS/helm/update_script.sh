#!/bin/bash
 
# Define repositories and services

declare -A services=(

  ["rs-cart"]="securityanddevops/rs-cart"

  ["rs-catalogue"]="securityanddevops/rs-catalogue"

  ["rs-dispatch"]="securityanddevops/rs-dispatch"

  ["rs-mongo"]="securityanddevops/rs-mongo"

  ["rs-mysql"]="securityanddevops/rs-mysql"

  ["rs-payment"]="securityanddevops/rs-payment"

  ["rabbitmq"]="securityanddevops/rabbitmq"

  ["rs-ratings"]="securityanddevops/rs-ratings"

  ["rs-redis"]="securityanddevops/redis"

  ["rs-shipping"]="securityanddevops/rs-shipping"

  ["rs-user"]="securityanddevops/rs-user"

  ["rs-web"]="securityanddevops/rs-web"

)
 
VALUES_FILE="./values.yaml"
 
# Function to get the latest tag

get_latest_tag() {

  local repo=$1

  curl -s "https://hub.docker.com/v2/repositories/securityanddevops/$repo/tags/" | jq -r '.results[0].name'

}
 
# Update values.yaml with the latest tags for specific images

for service in "${!services[@]}"; do

  latest_tag=$(get_latest_tag "${services[$service]}")

  echo "Updating $service with the latest tag: $latest_tag"

  yq e -i ".images.$service.version = \"$latest_tag\"" $VALUES_FILE

done
 
echo "Updated $VALUES_FILE with the latest tags."

 
