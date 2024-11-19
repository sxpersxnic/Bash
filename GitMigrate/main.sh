#!/usr/bin/bash

set -e

GITHUB_TOKEN=""
GITHUB_USERNAME="sxpersxnic"

echo -n "Enter target for migration: "; read -r migTarget

echo "${GITHUB_TOKEN}" | gh auth login --with-token

function deleteMigratedRepos() {
  local target=${1}

  repos=$(gh repo list --json name --jq '.[].name')

  for repo in ${repos}; do
    if [[ ${repo} == ${target}-* ]]
      echo "Deleting: ${repo}"
      sleep 2
      gh repo delete ${repo} --yes
    fi
  done
}
function migrateRepo() {
  local repo=${1}
  local target=${repo:0:3}

  cd ${HOME}
  gh repo clone ${repo}
  rm -fr "${HOME}/${repo}/.git"
  mv ${repo} "${HOME}/${target}"
  echo "  - [${repo}](https://github.com/sxpersxnic/${target}/tree/main/${repo})" >> "${HOME}/${target}/README.md"
}

function migrateRepos() {

  local target=${1}

  repos=$(gh repo list --json name --jq '.[].name')
  
  for repo in ${repos}; do
      if [[ ${repo} == ${target}-* ]]
        migrateRepo() "${repo}"
      fi
  done
}

function initTarget() {
  local target=${1}
  gh repo create ${target} --private
  mkdir -p "${HOME}/${target}"
  echo "# ${target}" > "./README.md"
  echo "## Includes" >> "./README.md"
  cd "${HOME}/${target}"
  git init
  git remote add github git@github.com:sxpersxnic/${target}.git
  cd "${HOME}"
  migrateRepos ${target}
  cd "${HOME}/${target}"
  git add .
  git commit -m "Migration for target: ${target}"
  git push github main
  cd ${HOME}
  echo "Migration for ${target} done"
}

echo "Starting migration on ${pwd}"
initTarget ${migTarget}

echo "Target: "
ls -a "${HOME}/${migTarget}"

echo -n "Delete repositories matching ${migTarget}-*? (y|N)"; read -r deleteChoice

case ${deleteChoice} in
  y|Y)
      deleteMigratedRepos ${migTarget}
    ;;
  *)
    echo "Skippin deletion..."
    ;;
esac

echo -n "Restart? (y|N): "; read -r choice

case ${choice} in
  y|Y)
      echo "Restarting..."
      exec "$0"
    ;;
  *) 
      echo "Exiting..."
      exit 0
    ;;
esac