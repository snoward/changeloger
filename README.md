# Changeloger - GitLab CI Components

GitLab CI components for automated changelog management and deployment notifications.

## Components

### prepare-release-notes

Fetches merged merge requests from GitLab API and generates release notes.

**Inputs:**
- `stage` (default: `deploy`)
- `changes_md_token` (default: `$CHANGES_MD_TOKEN`) - GitLab API token
- `changelog_file` (default: `CHANGELOG.md`) - Changelog file to read last update timestamp from
- `release_notes_file` (default: `release_notes.txt`) - Output file for release notes

**Artifacts:** Creates `release_notes.txt` (1 day expiry)

**Usage:**
```yaml
include:
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/prepare-release-notes@main

prepare-release-notes:
  stage: release
```

---

### actualize-changelog

Updates CHANGELOG.md with release notes and commits changes back to repository.

**Inputs:**
- `stage` (default: `deploy`)
- `changelog_header` (default: `"Список релизов"`) - Header text for changelog
- `changes_md_token` (default: `$CHANGES_MD_TOKEN`) - GitLab API token for git push
- `changelog_file` (default: `CHANGELOG.md`) - Changelog file to update
- `release_notes_file` (default: `release_notes.txt`) - Input file with release notes

**Usage:**
```yaml
include:
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/actualize-changelog@main
    inputs:
      changelog_header: "Releases"

actualize-changelog:
  stage: release
  needs:
    - prepare-release-notes
```

---

### send-notification

Sends deployment notification to Telegram with release notes.

**Inputs:**
- `stage` (default: `deploy`)
- `telegram_token` (default: `$TELEGRAM_TOKEN`) - Telegram bot token
- `telegram_chat_id` (default: `$TELEGRAM_CHAT_ID`) - Telegram chat ID
- `release_notes_file` (default: `release_notes.txt`) - File with release notes to send

**Usage:**
```yaml
include:
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/send-notification@main

send-notification:
  stage: notify
  needs:
    - prepare-release-notes
```

---

## Complete Example

```yaml
include:
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/prepare-release-notes@main
    inputs:
      stage: deploy
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/actualize-changelog@main
    inputs:
      stage: deploy
  - component: $CI_SERVER_FQDN/your-namespace/changeloger/send-notification@main
    inputs:
      stage: notify

stages:
  - deploy
  - notify

actualize-changelog:
  needs:
    - prepare-release-notes

send-notification:
  needs:
    - prepare-release-notes
```

## Required CI/CD Variables

Set these in your GitLab project settings (Settings → CI/CD → Variables):

- `CHANGES_MD_TOKEN` - GitLab personal access token with `api` and `write_repository` scopes
- `TELEGRAM_TOKEN` - Telegram bot token (optional, only for send-notification)
- `TELEGRAM_CHAT_ID` - Telegram chat ID (optional, only for send-notification)
