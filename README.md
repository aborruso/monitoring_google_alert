# Google Alert Monitoring

This repository provides a template to automatically monitor Google Alerts via GitHub Actions, creating a historical timeline of the results. It can also be used as a standalone command-line tool to convert a single feed.

## What is Google Alerts?

[Google Alerts](https://www.google.com/alerts) is a content change detection and notification service. It sends emails or creates web feeds summarizing new web content that matches a user's search terms. One of the delivery options for these notifications is an **RSS feed**, which this project leverages.

## Setup for Project-Based Monitoring

Follow these steps if you want to use this repository as a template for continuous, daily monitoring.

### 1. Get Your Google Alert RSS Feed URL

1.  Go to [Google Alerts](https://www.google.com/alerts).
2.  Enter the topic you want to monitor and click **"Show options"**.
3.  In the **"Deliver to"** dropdown, select **"RSS feed"** and click **"Create Alert"**.
4.  Right-click on the RSS icon next to your alert and select **"Copy link address"**.

### 2. Configure the `config.yml` File

For each feed you want to monitor, add an entry to `config.yml` with the following fields:
*   `url_feed`: The RSS feed URL you copied.
*   `title`: A descriptive title for your alert.
*   `alias`: A unique name in `snake_case` format, used to identify the source of each record.

**Example `config.yml`:**

```yaml
- url_feed: "https://www.google.com/alerts/feeds/..."
  title: "My Custom Alert"
  alias: "my_custom_alert"
```

### 3. Grant Write Permissions to the GitHub Action

For the automated workflow to save results back to the repository, you must grant it write permissions.

1.  In your repository, go to **Settings > Actions > General**.
2.  Scroll to **"Workflow permissions"** and select **"Read and write permissions"**.
3.  Click **"Save"**.

## Usage

This tool can be run in two modes.

### 1. Batch Mode (for Project Monitoring)

This mode reads the `config.yml` file and updates the `data/timeline.jsonl` timeline. It is intended to be run from within the project directory.

```bash
# Manually update the timeline
make update
```

The GitHub Action in this repository uses this mode to run automatically every day.

### 2. Single Feed Mode (for Quick Conversion)

Use the `--feed` flag to convert a single RSS feed URL directly to JSONLines. The output is printed to standard output (`stdout`) and is not saved to a file.

```bash
# Process a single feed and print to the console
bash script/update_feed.sh --feed "YOUR_GOOGLE_ALERT_RSS_URL"
```

If you install the script using `make install`, you can use the `google-alert-monitor` command from any location:

```bash
google-alert-monitor --feed "YOUR_GOOGLE_ALERT_RSS_URL"
```
