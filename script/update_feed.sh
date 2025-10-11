#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipelines return the exit status of the last command to exit with a non-zero status.
set -o pipefail

# --- Single Feed Mode ---
# If the script is called with the --feed argument, process a single URL to stdout.
if [ "${1:-}" == "--feed" ]; then
  url_feed="${2:?URL must be provided after --feed}"

  # Create a temporary file for the download.
  tmp_xml_file=$(mktemp)
  # Ensure the temporary file is removed on script exit.
  trap 'rm -f "$tmp_xml_file"' EXIT

  # Download the feed.
  if curl -sL -f "$url_feed" -o "$tmp_xml_file"; then
    # Transform to JSONLines on stdout, without the 'alias' field.
    xq -cr '
      .feed.entry[] |
      {
        id: .id,
        title: .title["#text"],
        link: (
          (.link["@href"] | capture("url=(?<real>[^&]+)") | .real)
        ),
        published: .published,
        updated: .updated,
        content: .content["#text"]
      }' "$tmp_xml_file"
  else
    echo "Failed to download feed from URL: ${url_feed}" >&2
    exit 1
  fi
  # Exit successfully after processing the single feed.
  exit 0
fi

# --- Default Batch Mode ---

# Get the absolute path of the script's directory.
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for config file before proceeding.
CONFIG_FILE="${folder}/../config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: config.yml not found. This mode requires running from within the project directory." >&2
  echo "To process a single feed from any location, please use the --feed <URL> argument." >&2
  exit 1
fi

# Create data and temporary directories if they don't exist.
mkdir -p "${folder}"/../data
mkdir -p "${folder}"/tmp

# Read the YAML config file and process each feed entry.
yq -c '.[]' "$CONFIG_FILE" | while read -r feed; do
  # Extract feed URL, title, and alias from the config.
  url_feed=$(echo "$feed" | yq -r '.url_feed')
  titolo=$(echo "$feed" | yq -r '.titolo' | tr ' ' '_')
  alias=$(echo "$feed" | yq -r '.alias')

  # Download the RSS feed, failing silently on server errors (-f).
  if curl -sL -f "$url_feed" -o "${folder}/tmp/${alias}.xml"; then
    # If download is successful, parse the XML and append to the timeline.
    xq -cr '
      .feed.entry[] |
      {
        alias: "'"${alias}"'",
        id: .id,
        title: .title["#text"],
        link: (
          (.link["@href"] | capture("url=(?<real>[^&]+)") | .real)
        ),
        published: .published,
        updated: .updated,
        content: .content["#text"]
      }' "${folder}/tmp/${alias}.xml" >> "${folder}/../data/timeline.jsonl"
  else
    # If download fails, print an error message to stderr and continue.
    echo "Failed to download feed for alias: ${alias}" >&2
  fi
done

# Use Miller to sort the timeline file in-place.
# It sorts by 'published' date in reverse order, then groups by 'link',
# and keeps only the first (most recent) entry for each link to ensure uniqueness.
mlr -I --jsonl sort -tr published then group-by link then head -n 1 -g link "${folder}/../data/timeline.jsonl"

# Clean up the temporary directory.
rm -rf "${folder}/tmp"
