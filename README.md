# skyblue

[![Build skyblue](https://github.com/tbshfr/skyblue/actions/workflows/build.yaml/badge.svg)](https://github.com/tbshfr/skyblue/actions/workflows/build.yaml)

This is a custom Fedora Silverblue image. If you want to use it, you probably want to fork it and build your own.

## Install
- Install [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/)

- Verify image before rebasing (you can find cosign.pub in the root of this repo)
```
cosign verify --key cosign.pub ghcr.io/tbshfr/skyblue
```

- Rebase to the unsigned image, to get the proper signing keys: 
```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/tbshfr/skyblue
```
`systemctl reboot`

- Rebase to a signed image to finish the installation
```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/tbshfr/skyblue
```
`systemctl reboot`

## Troubleshooting

### Does Not Automatically Update
If you are running rpm-ostree version 2026.1:
```
$ rpm-ostree --version
rpm-ostree:
 Version: '2026.1'
 Git: 4cacb30261fdf34d543989aad920ce685a271d92
```
After the second update attempt, it exits without an error code and without actually updating.

You can fix this by downgrading to an older version and then updating to a newer one:
```
# add a temporary overlay (not persistent between reboots)
sudo rpm-ostree usroverlay
# install an older rpm-ostree version inside the temporary overlay
sudo dnf5 install -y --from-repo=updates-archive rpm-ostree-2025.12-1.fc43
rpm-ostree upgrade
sudo systemctl reboot
``` 

## Credits
This project was heavily inspired by:
- [bluefusion](https://github.com/aguslr/bluefusion)
- [blueconfig](https://github.com/aorith/blueconfig)
- [bluestream](https://github.com/yasershahi/bluestream)
- [ypsidanger.com](https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/)