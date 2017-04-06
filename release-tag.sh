#!/usr/bin/env bash

set -o errexit # Abort script at first error (command exits non-zero).

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)

: "${PUSH:=false}"

if [[ -z $1 ]] ; then
  >&2 echo "Missing argument!"
  echo "Usage:"
  echo "  release-tag.sh <version> [<push>]"
  echo ""
  echo "Example:"
  echo "  release-tag.sh 0.9.3"
  echo "  release-tag.sh 0.9.3 push"
  exit 1
else
  TAG="$1"
  if [[ $2 = push ]] ; then
    PUSH="true"
  fi
fi

if [[ -n $(git status --porcelain 2> /dev/null) ]] ; then
  >&2 echo "${red}Error:${reset} You got untracked changes, exiting!"
  exit 1
fi

echo "${green}
██╗   ██╗ █████╗ ███╗   ███╗██████╗     ████████╗ █████╗  ██████╗  ██████╗ ███████╗██████╗
██║   ██║██╔══██╗████╗ ████║██╔══██╗    ╚══██╔══╝██╔══██╗██╔════╝ ██╔════╝ ██╔════╝██╔══██╗
██║   ██║███████║██╔████╔██║██████╔╝       ██║   ███████║██║  ███╗██║  ███╗█████╗  ██████╔╝
╚██╗ ██╔╝██╔══██║██║╚██╔╝██║██╔═══╝        ██║   ██╔══██║██║   ██║██║   ██║██╔══╝  ██╔══██╗
 ╚████╔╝ ██║  ██║██║ ╚═╝ ██║██║            ██║   ██║  ██║╚██████╔╝╚██████╔╝███████╗██║  ██║
  ╚═══╝  ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝            ╚═╝   ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝
                                                                     by magnetic.io
${reset}"

# Ensure we're tagging vamp-docker-images as well
if [[ "$( git tag --list $TAG )" = "$TAG" ]] ; then
  if [[ "$( git describe --tags )" != "$TAG" ]] ; then
    echo "${yellow}Warning:${reset} Tag ${TAG} already exists but you're on a different commit:"
    git show --no-patch
    echo
    >&2 echo "${red}Error: Exiting!${reset}"
    exit 1
  fi
else
  git tag "$TAG"
fi

workspace=${root}/target
mkdir -p ${workspace}

tag() {
  project=$1
  url="git@github.com:magneticio/${project}.git"
  echo "${green}project: ${yellow}${project}${reset}"
  cd ${workspace}

  if [[ -d ${workspace}/${project} ]] ; then
    echo "${green}updating existing repository${reset}"

    cd ${workspace}/${project}

    git reset --hard
    git checkout master
    git pull

  else
    git clone --depth=200 "$url"
    cd ${workspace}/${project}

  fi

  if [[ "$( git describe --tags )" != "$TAG" ]] ; then
    git tag "$TAG" || { echo "${yellow}${project}: tag exists, ${TAG}, continuing${reset}"; git checkout "$TAG"; }
  fi

  if [[ "$PUSH" = "true" ]] ; then
    git push --tags
  fi
}

tag vamp
tag vamp-haproxy
tag vamp-elasticsearch
tag vamp-zookeeper
tag vamp-etcd
tag vamp-redis
tag vamp-consul
tag vamp-mysql
tag vamp-dcos
tag vamp-docker
tag vamp-kubernetes
tag vamp-rancher
tag vamp-lifter
tag vamp-ui
tag vamp-artifacts
tag vamp-runner
tag vamp-gateway-agent
tag vamp-workflow-agent
