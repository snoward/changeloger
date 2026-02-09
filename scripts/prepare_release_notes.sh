#!/bin/sh
set -e

CHANGELOG_FILE="CHANGELOG.md"

touch "$CHANGELOG_FILE"
LAST_DATE=$(tail -n 1 "$CHANGELOG_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z' || echo "")
RELEASE_NOTES=$(curl --header "Authorization: Bearer ${CHANGES_MD_TOKEN}" --url "https://git.skbkontur.ru/api/v4/projects/${CI_PROJECT_ID}/merge_requests?state=merged&updated_after=${LAST_DATE}" | jq -r --arg DATE "$LAST_DATE" 'map(select(.merged_at > $DATE)) | "- " + .[].title')
if [ -z "$RELEASE_NOTES" ]; then
    echo "No new merge requests found since $LAST_DATE."
    exit 0
fi
echo "${RELEASE_NOTES}" > release_notes.txt
