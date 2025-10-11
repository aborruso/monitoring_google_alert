#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/../data
mkdir -p "${folder}"/tmp

yq -c '.[]' "${folder}"/../config.yml | while read -r feed; do
  url_feed=$(echo "$feed" | yq -r '.url_feed')
  titolo=$(echo "$feed" | yq -r '.titolo' | tr ' ' '_')
  alias=$(echo "$feed" | yq -r '.alias')

  curl -sL "$url_feed" -o "${folder}/tmp/${alias}.xml"

  xq -cr '
    .feed.entry[] |
    {
      alias: "'"${alias}"'",
      id: .id,
      link: (
        (.link["@href"] | capture("url=(?<real>[^&]+)") | .real)
      ),
      published: .published,
      updated: .updated,
      content: .content["#text"]
    }' "${folder}/tmp/${alias}.xml" >> "${folder}/../data/timeline.jsonl"
done

mlr -I --jsonl sort -tr published then group-by link then head -n 1 -g link "${folder}/../data/timeline.jsonl"
