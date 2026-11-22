# Additional Binaries and Fonts

Add one object per binary to `build/config/binaries.json`:

```json
{
	"name": "tool",
	"version": "1.2.3",
	"sha256": "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
	"url": "https://example.com/tool-{version}-{arch}.tar.gz",
	"destination": "/usr/bin/tool",
	"binary_path": "tool-{version}/bin/tool"
}
```

The URL and binary path can contain `{version}` and `{arch}` placeholders.</br>
Leave `binary_path` empty for direct binaries; for tar or zip archives, set it to the executables path inside the archive.

Same principle applies to fonts, just add them to `build/config/fonts.json`

## Verify Binaries:

### Cosign
```
cosign verify-blob \
  --bundle cosign-linux-amd64.sigstore.json \
  --certificate-identity keyless@projectsigstore.iam.gserviceaccount.com \
  --certificate-oidc-issuer https://accounts.google.com \
  cosign-linux-amd64
```

### DNSControl
```
cosign verify-blob checksums.txt \
  --bundle checksums.txt.sigstore.json \
  --certificate-identity-regexp 'https://github\.com/DNSControl/dnscontrol/\.github/workflows/release_draft\.yml@refs/(tags|heads)/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com

sha256sum --ignore-missing -c checksums.txt
```
