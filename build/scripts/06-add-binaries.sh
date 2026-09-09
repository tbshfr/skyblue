#!/usr/bin/env bash
set -eux -o pipefail

manifest="${1:-/tmp/config/binaries.json}"
architecture="$(uname -m)"
workdir=""
manifest_rows=""

cleanup_download() {
	[[ -z "${workdir}" ]] || rm --force --recursive "${workdir}"
}

cleanup() {
	cleanup_download
	[[ -z "${manifest_rows}" ]] || rm --force "${manifest_rows}"
}

trap cleanup EXIT

manifest_rows="$(mktemp)"
jq --exit-status --raw-output '
	.binaries[] |
	[.name, .version, .sha256, .url, .destination, (.binary_path // "")] |
	@tsv
' "${manifest}" > "${manifest_rows}"

while IFS=$'\t' read -r name version expected_sha256 url destination binary_path; do
	if [[ -z "${name}" || -z "${version}" || -z "${expected_sha256}" || -z "${url}" || -z "${destination}" ]]; then
		echo "Invalid binary entry: name, version, sha256, url, and destination are required" >&2
		exit 1
	fi

	if [[ ! "${expected_sha256}" =~ ^[[:xdigit:]]{64}$ ]]; then
		echo "Invalid SHA-256 checksum for ${name}" >&2
		exit 1
	fi

	url="${url//\{version\}/${version}}"
	url="${url//\{arch\}/${architecture}}"
	binary_path="${binary_path//\{version\}/${version}}"
	binary_path="${binary_path//\{arch\}/${architecture}}"
	workdir="$(mktemp --directory)"
	download="${workdir}/download"
	executable="${download}"

	curl --fail --location --retry 3 --output "${download}" "${url}"
	echo "${expected_sha256}  ${download}" | sha256sum --check --status

	if [[ -n "${binary_path}" ]]; then
		executable="${workdir}/executable"
		archive_url="${url%%\?*}"
		archive_url="${archive_url%%\#*}"

		case "${archive_url}" in
			*.tar|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar.bz2|*.tbz2|*.tar.zst|*.tzst)
				tar --extract --file "${download}" --to-stdout "${binary_path}" > "${executable}"
				;;
			*.zip)
				unzip -p "${download}" "${binary_path}" > "${executable}"
				;;
			*)
				echo "Unsupported archive format for ${name}: ${url}" >&2
				exit 1
				;;
		esac
	fi

	install --mode=0755 -D "${executable}" "${destination}"
	cleanup_download
	workdir=""
done < "${manifest_rows}"
