#!/bin/sh
set -e

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
	'Destruction of the Introduction chapter.
  
This script assumes that you jumped straight into this chapter.
If that is not the case (if you are continuing from the previous
chapter), please answer with "No" when asked whether you are
ready to start.'

gum confirm '
Are you ready to start?
Select "Yes" only if you did NOT follow the story from the start (if you jumped straight into this chapter).
Feel free to say "No" and inspect the script if you prefer setting up resources manually.
' || exit 0

echo "
## You will need following tools installed:
|Name            |Required             |More info                                          |
|----------------|---------------------|---------------------------------------------------|
|Linux Shell     |Yes                  |Use WSL if you are running Windows                 |
|Docker          |Yes                  |'https://docs.docker.com/engine/install'           |
|kind CLI        |Yes                  |'https://kind.sigs.k8s.io/docs/user/quick-start/#installation'|
" | gum format

gum confirm "
Do you have those tools installed?
" || exit 0

##############
# Crossplane #
##############

rm a-team/intro.yaml

git add .

git commit -m "Remove intro"

git push

COUNTER=$(kubectl get managed --no-headers | grep -v database | wc -l)

while [ $COUNTER -ne 0 ]; do
    echo "$COUNTER resources still exist. Waiting for them to be deleted..."
    COUNTER=$(kubectl get managed --no-headers | grep -v database | wc -l)
done

#########################
# Control Plane Cluster #
#########################

kind delete cluster
