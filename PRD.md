# Google Alert Monitoring

## Introduction

This project downloads one or more Google Alert RSS feeds daily via a GitHub workflow, transforms them into JSONLines format, and appends them to create a historical timeline.

## Features

* **Data Appending**: On each run, the script appends new data to the existing JSONLines file or creates a new one.
* **Sorting and Deduplication**: The JSONLines file is versioned, sorted by publication date (`published`), and deduplicated to remove any duplicate rows.
* **Reusable Template**: The repository is designed to be a template, allowing anyone to monitor their own Google Alert feeds by cloning and configuring the project.

## Configuration

In the project root, there is a configuration file (`config.yml`) with the following fields:

* `url_feed`: The unique URL of the RSS feed.
* `title`: A descriptive name for the feed.
* `alias`: A unique alias in *snake_case* format, which will be added as an extra field in the output JSONLines file.

## Tools Used

If needed:

* `xq`
* `jq`
* `duckdb`
* `miller`

## Examples

### XML to JSONLines Transformation

The following `xq` command shows how to transform the Google Alert XML feed into JSONLines format:

```xml
xq -cr '''
.feed.entry[] |
{
  id: .id,
  link: (
    (.link["@href"] | capture("url=(?<real>[^&]+)") | .real)
  ),
  published: .published,
  updated: .updated,
  content: .content["#text"]
}''' 16384461912871559641.xml
```

### Example Feed

* [Google Alert Feed](https://www.google.com/alerts/feeds/15244278077982194024/16384461912871559641)