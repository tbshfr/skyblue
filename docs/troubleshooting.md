# Troubleshooting

## Cannot SSH Into GNOME Boxes VMs
See [vm-ssh-vsock.md](vm-ssh-vsock.md).

## Does Not Automatically Update
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
