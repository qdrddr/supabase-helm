#!/bin/bash
repo_version=$(grep '^version:' ./charts/supabase/Chart.yaml | awk '{print $2}')
git fetch --tags
git checkout v${repo_version}

helm package ./charts/supabase -d build/
helm repo index ./
# sed 's+build+head+g' ./index.yaml > ./index.yaml

# Crossplatform sed workaround from: https://unix.stackexchange.com/questions/92895/how-can-i-achieve-portability-with-sed-i-in-place-editing
case $(sed --help 2>&1) in
  *GNU*) set sed -i;;
  *) set sed -i '';;
esac

#https://raw.githubusercontent.com/qdrddr/supabase-helm/refs/tags/${repo_version}/build
"$@" -e "s+build+https://raw.githubusercontent.com/qdrddr/supabase-helm/refs/tags/${repo_version}/build+g" ./index.yaml

git add *
git commit -m "Update index.yaml with new URL for version ${repo_version}"
git push origin HEAD:refs/tags/v${repo_version} --force