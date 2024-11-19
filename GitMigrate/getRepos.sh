#!/usr/bin/bash
page=1
per_page=100
endCursor=null

while true; do
    response=$(gh api graphql -f query='
    query($endCursor: String) {
      viewer {
        repositories(first: 100, after: $endCursor) {
          nodes {
            name
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }' -f endCursor="$endCursor")

    repos=$(echo "$response" | jq -r '.data.viewer.repositories.nodes[].name')
    echo "$repos" >> repos.txt

    hasNextPage=$(echo "$response" | jq -r '.data.viewer.repositories.pageInfo.hasNextPage')
    endCursor=$(echo "$response" | jq -r '.data.viewer.repositories.pageInfo.endCursor')

    if [ "$hasNextPage" != "true" ]; then
        break
    fi
done