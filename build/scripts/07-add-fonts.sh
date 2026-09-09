#!/usr/bin/env bash
set -eux -o pipefail

manifest="${1:-/tmp/fonts.json}"
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
	.fonts[] |
	[.name, .version, .sha256, .url, .destination] |
	@tsv
' "${manifest}" > "${manifest_rows}"

while IFS=$'\t' read -r name version expected_sha256 url destination; do
	if [[ -z "${name}" || -z "${version}" || -z "${expected_sha256}" || -z "${url}" || -z "${destination}" ]]; then
		echo "Invalid font entry: name, version, sha256, url, and destination are required" >&2
		exit 1
	fi

	if [[ ! "${expected_sha256}" =~ ^[[:xdigit:]]{64}$ ]]; then
		echo "Invalid SHA-256 checksum for ${name}" >&2
		exit 1
	fi

	url="${url//\{version\}/${version}}"
	workdir="$(mktemp --directory)"
	download="${workdir}/download"
	extract_dir="${workdir}/fonts"
	mkdir --parents "${extract_dir}"

	curl --fail --location --retry 3 --output "${download}" "${url}"
	echo "${expected_sha256}  ${download}" | sha256sum --check --status

	archive_url="${url%%\?*}"
	archive_url="${archive_url%%\#*}"
	case "${archive_url}" in
		*.tar|*.tar.gz|*.tgz|*.tar.xz|*.txz|*.tar.bz2|*.tbz2|*.tar.zst|*.tzst)
			tar --extract --file "${download}" --directory "${extract_dir}"
			;;
		*.zip)
			unzip -q "${download}" -d "${extract_dir}"
			;;
		*)
			echo "Unsupported archive format for ${name}: ${url}" >&2
			exit 1
			;;
	esac

	mapfile -d '' font_files < <(find "${extract_dir}" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print0)
	if (( ${#font_files[@]} == 0 )); then
		echo "No font files found for ${name}" >&2
		exit 1
	fi

	install --directory --mode=0755 "${destination}"
	install --mode=0644 "${font_files[@]}" "${destination}/"
	cleanup_download
	workdir=""
done < "${manifest_rows}"