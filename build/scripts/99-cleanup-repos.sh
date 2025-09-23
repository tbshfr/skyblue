#!/usr/bin/bash
set -eux -o pipefail

repos_to_disable=(
    "/etc/yum.repos.d/vscode.repo"
    "/etc/yum.repos.d/fedora-cisco-openh264.repo"
)

for repo_file in "${repos_to_disable[@]}"; do
    if [ -f "$repo_file" ]; then
        echo "Disabling repository: $repo_file"
        sed -i 's@enabled=1@enabled=0@g' "$repo_file"
    else
        echo "Repository file not found: $repo_file"
    fi
done