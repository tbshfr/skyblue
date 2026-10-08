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

## Documentation
- [Additional Binaries and Fonts](docs/binaries-and-fonts.md)
- [Troubleshooting](docs/troubleshooting.md)
- [SSH into GNOME Boxes VMs via vsock](docs/vm-ssh-vsock.md)

## Credits
This project was heavily inspired by:
- [bluefusion](https://github.com/aguslr/bluefusion)
- [blueconfig](https://github.com/aorith/blueconfig)
- [bluestream](https://github.com/yasershahi/bluestream)
- [ypsidanger.com](https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/)