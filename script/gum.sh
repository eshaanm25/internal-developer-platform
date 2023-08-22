#!/bin/sh

set -e

function style() {
  gum style --border normal --margin "1" --padding "1 1" --border-foreground 212 "$1"
}

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "$(gum style --foreground 212 'Internal Developer Platform') Configuration Script."

gum confirm "Have You Deployed Resources in AWS and Port using Terraform?" || { style "Please Deploy Resources before running this Script"; exit 1; }

command -v aws >/dev/null 2>&1 || { echo "This Script Requires the AWS CLI but it's not installed.  Aborting."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "This Script Requires the Kubectl CLI but it's not installed.  Aborting."; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "This Script Requires the GH CLI but it's not installed.  Aborting."; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "This Script Requires the yq but it's not installed.  Aborting."; exit 1; }

if [ ! -f "script/temp/access" ]; then
   echo '[default]' >> script/temp/access
   echo "aws_access_key_id=$(gum input --placeholder "AWS Access Key" --password)" >> script/temp/access
   echo "aws_secret_access_key=$(gum input --placeholder "AWS Secret Access Key" --password)" >> script/temp/access
   echo 'region=us-east-1' >> script/temp/access
else
   echo "AWS Credentials Already Setup. Continuing..."
fi

if [ ! -f "script/temp/portClientID" ] || [ ! -f "script/temp/portClientSecret" ]; then
    gum input --placeholder "Port Client ID" --password > script/temp/portClientID
    gum input --placeholder "Port Client Secret" --password > script/temp/portClientSecret
else
   echo "Port Credentials Already Setup. Continuing..."
fi

export AWS_CONFIG_FILE="script/temp/access"
export AWS_SHARED_CREDENTIALS_FILE="script/temp/access"

gum spin --spinner meter --title "Getting ArgoCD Password..." -- sh -c "aws secretsmanager get-secret-value --secret-id argocd | yq -r eval ".SecretString" > script/temp/argoCDAdminPassword"
gum spin --spinner meter --title "Setting kubectl Context..." -- aws eks update-kubeconfig --name orchestration-cluster 
gum spin --spinner globe --title "Getting ArgoCD Domain" -- sh -c "kubectl get svc argocd-nlb -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' > script/temp/argoCDHostname"

gum spin --spinner meter --title "Setting ARGO_PASSWORD Secret in GitHub" -- sh -c "gh secret set ARGO_ENDPOINT < script/temp/argoCDAdminPassword"
gum spin --spinner meter --title "Setting PORT_CLIENT_ID Secret in GitHub" -- sh -c "gh secret set ARGO_ENDPOINT < script/temp/portClientID"
gum spin --spinner meter --title "Setting PORT_CLIENT_SECRET Secret in GitHub" -- sh -c "gh secret set ARGO_ENDPOINT < script/temp/portClientSecret"
gum spin --spinner meter --title "Setting ARGO_ENDPOINT Secret in GitHub" -- sh -c "gh secret set ARGO_ENDPOINT < script/temp/argoCDHostname"

gum style --bold --foreground 397 "Script Completed! Here's what you can do next:"
PORT=$(gum style --padding "1 1" --border double --border-foreground 212 "$(gum style --bold --foreground 325 'Onboard an Application with Port')" "$(gum style --foreground 212 'Visit') https://app.getport.io/self-serve")
ARGO=$(gum style --padding "1 1" --border double --border-foreground 212 "$(gum style --bold --foreground 325 'Login to ArgoCD')" "$(gum style --foreground 212 'Endpoint:') http://$(cat script/temp/argoCDHostname)" "$(gum style --foreground 212 'Username:') admin" "$(gum style --foreground 212 'Password:') $(cat script/temp/argoCDAdminPassword)")
gum join --align left --vertical "$PORT" "$ARGO"