#!/usr/bin/bash
set -eux -o pipefail

# rpm repos
# Since Fedora 45, packaged repo configs live in /usr/share/dnf5/repos.d, see
# https://fedoraproject.org/wiki/Changes/RelocateRpmRepoConfigsToUsr
repo_dirs=(
    "/usr/share/dnf5/repos.d"
    "/etc/yum.repos.d"
)

repos_to_disable=(
    "vscode.repo"
    "gh-cli.repo"
    "fedora-cisco-openh264.repo"
    "rpmfusion-free.repo"
    # "rpmfusion-nonfree.repo"
    "rpmfusion-free-updates.repo"
    # "rpmfusion-nonfree-updates.repo"
)

for repo in "${repos_to_disable[@]}"; do
    found=false
    for repo_dir in "${repo_dirs[@]}"; do
        repo_file="${repo_dir}/${repo}"
        if [ -f "$repo_file" ]; then
            echo "Disabling repository: $repo_file"
            sed -i 's@enabled=1@enabled=0@g' "$repo_file"
            found=true
        fi
    done
    if [ "$found" = false ]; then
        echo "Repository file not found: $repo"
    fi
done

# 01-install-multimedia.sh enables openh264 via an override in /etc/dnf/repos.override.d,
# which takes precedence over the repo file, so it has to be removed for the sed above to take effect
dnf5 config-manager unsetopt fedora-cisco-openh264.enabled
