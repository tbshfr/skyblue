# skyblue

[![Build skyblue](https://github.com/tbshfr/skyblue/actions/workflows/build.yaml/badge.svg)](https://github.com/tbshfr/skyblue/actions/workflows/build.yaml)

Custom Fedora Silverblue image that is propably not ready for production.

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

## Credits
This project was heavily inspired by:
- [bluefusion](https://github.com/aguslr/bluefusion)
- [blueconfig](https://github.com/aorith/blueconfig)
- [bluestream](https://github.com/yasershahi/bluestream)
- [ypsidanger.com](https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/)