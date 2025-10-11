# Google Alert Monitoring

This repository provides a template to automatically monitor Google Alerts via GitHub Actions, creating a historical timeline of the results.

## What is Google Alerts?

[Google Alerts](https://www.google.com/alerts) is a content change detection and notification service. It sends emails or creates web feeds summarizing new web content that matches a user's search terms. One of the delivery options for these notifications is an **RSS feed**, which provides a structured XML file that can be programmatically accessed. This project leverages these RSS feeds.

## How to Use This Repository

This repository is a template that you can use to set up your own monitoring system for any Google Alert feed. The process involves getting your custom RSS feed URLs from Google Alerts and adding them to a configuration file. A GitHub Action will then automatically fetch, process, and store the results daily.

### Setup Instructions

#### 1. Get Your Google Alert RSS Feed URL

1.  Go to [Google Alerts](https://www.google.com/alerts).
2.  Enter the topic you want to monitor.
3.  Click on **"Show options"**.
4.  In the **"Deliver to"** dropdown, select **"RSS feed"**.
5.  Click **"Create Alert"**.
6.  An RSS icon will appear next to your alert. Right-click on it and select **"Copy link address"**. This is the URL you will need.

#### 2. Configure the `config.yml` File

1.  Open the `config.yml` file in the root of this repository.
2.  For each feed you want to monitor, add an entry with the following fields:
    *   `url_feed`: The RSS feed URL you copied from Google Alerts.
    *   `title`: A descriptive title for your alert.
    *   `alias`: A unique, simple name in `snake_case` format (e.g., `my_topic_alert`). This will be added to each record in the output file to identify its source.

**Example `config.yml`:**

```yaml
- url_feed: "https://www.google.com/alerts/feeds/..."
  title: "My Custom Alert"
  alias: "my_custom_alert"

- url_feed: "https://www.google.com/alerts/feeds/..."
  title: "Another Topic"
  alias: "another_topic"
```

#### 3. Run the Monitoring

Once you have configured your `config.yml` and pushed it to your own GitHub repository (created from this template), the monitoring will start automatically.

*   **Automatic Updates**: The GitHub Action is scheduled to run every day at 3:00 AM UTC. You can customize this schedule by editing the `cron` expression in `.github/workflows/update.yml`.
*   **Manual Updates**: You can also trigger the workflow manually by going to the **Actions** tab in your repository, selecting the **"Update Feed"** workflow, and clicking **"Run workflow"**.

#### 4. Grant Write Permissions to the GitHub Action

**Important**: For the workflow to be able to commit the updated `timeline.jsonl` file back to your repository, you must grant it write permissions.

1.  In your repository, go to **Settings > Actions > General**.
2.  Scroll down to the **"Workflow permissions"** section.
3.  Select the **"Read and write permissions"** option.
4.  Click **"Save"**.

### Output

The collected data is stored in the `data/timeline.jsonl` file. Each line is a JSON object representing an alert item, enriched with your custom alias:

```json
{"alias": "my_custom_alert", "id": "...", "link": "...", "published": "...", "updated": "...", "content": "..."}
```

This file is automatically sorted and deduplicated on each run.