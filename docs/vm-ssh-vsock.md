# SSH into GNOME Boxes VMs via vsock

## Background

GNOME Boxes is installed as a Flatpak (`org.gnome.Boxes`). The Flatpak ships its own libvirt and QEMU and runs VMs in `qemu:///session` with user-mode (slirp) networking. Every VM gets `10.0.2.15` and the host can't reach it. The sandbox has no setuid `qemu-bridge-helper`, so VMs can't be attached to the host's `virbr0` bridge either. Installing `libvirt-daemon-config-network` or enabling `virtnetworkd` on the host has no effect on Flatpak Boxes.

[vsock](https://man7.org/linux/man-pages/man7/vsock.7.html) is a socket between the host and a VM that bypasses the VM's network. The image needs no extra packages for it. The host already has `/dev/vhost-vsock` from the kernel and `/usr/lib/systemd/ssh_config.d/20-systemd-ssh-proxy.conf` from systemd. In the guest, [`systemd-ssh-generator`](https://www.freedesktop.org/software/systemd/man/latest/systemd-ssh-generator.html) binds sshd to vsock port 22 when it finds a vsock device.

## Guest requirements

- systemd 256 or newer (Fedora 41+, Debian 13, Ubuntu 24.10+)
- `openssh-server` installed. The sshd service doesn't need to be enabled, because the vsock socket starts sshd on demand.

## Setup

1. List the VMs and open one for editing:

   ```bash
   flatpak run --command=virsh org.gnome.Boxes -c qemu:///session list --all
   flatpak run --command=virsh org.gnome.Boxes -c qemu:///session edit <vm-name>
   ```

2. Add a vsock device inside `<devices>`. Each VM needs its own CID, starting at 3:

   ```xml
   <vsock model='virtio'>
     <cid auto='no' address='3'/>
   </vsock>
   ```

3. Shut the VM down and start it again. Rebooting from inside the guest doesn't apply the change.

4. In the guest, check that sshd is listening on vsock:

   ```bash
   systemctl status sshd-vsock.socket
   ```

5. Connect from the host. Pass a user name, since the systemd config logs in as `root` by default:

   ```bash
   ssh <user>@vsock/3
   ```

Changing VM settings in the Boxes UI rewrites the domain XML, so check afterwards that the `<vsock>` device is still there.

## Notes

- vsock only connects the host to its own VMs. The network and other VMs can't reach it.
- Any process on the host can connect to the guest's sshd. Flatpak apps and default Podman containers are blocked from vsock; `--privileged` containers such as Toolbx are not.
- The systemd ssh config skips host key checks for `vsock/*`, so a VM started with the same CID could pose as yours while it's off. Use key-only login and don't forward your agent (`-A`).
- The guest firewall doesn't filter vsock.

### Disable password login in the guest
add your key to the vm:
```
# run on host
ssh-copy-id <user>@vsock/3
```

add `/etc/ssh/sshd_config.d/10-hardening.conf` in the vm:
```bash
PermitRootLogin no
AllowUsers <user>
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
LoginGraceTime 1m
MaxAuthTries 5
ClientAliveInterval 300
ClientAliveCountMax 1
StreamLocalBindUnlink yes
```

### Check host keys with an alias (optional)

Fedora's `50-redhat.conf` contains `Match final all`, which makes ssh read the config a second time using `HostName`. The `vsock/*` block then matches the alias too, so set the host key options explicitly; ssh uses the first value it finds:

```
# ~/.ssh/config
Host dev-vm
    HostName vsock/3
    User <user> 
    HostKeyAlias dev-vm
    StrictHostKeyChecking ask
    UserKnownHostsFile ~/.ssh/known_hosts
    ProxyCommand /usr/lib/systemd/systemd-ssh-proxy %h %p
    ProxyUseFdpass yes
    CheckHostIP no
    RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra
```

Then connect with `ssh dev-vm`.

sshd sets up the `RemoteForward` before the login creates `/run/user/<uid>`. Unless the user is already logged in to the guest, the forward fails with `remote port forwarding failed for listen path`. To keep the runtime dir around after boot, enable lingering in the guest:

```bash
loginctl enable-linger <user>
```

### Turn off SSH over vsock for one VM

Remove the `<vsock>` device from the domain XML, or add `systemd.ssh_auto=no` to the guest's kernel command line.

On a Fedora guest:

```bash
sudo grubby --update-kernel=ALL --args=systemd.ssh_auto=no
```

On an rpm-ostree guest such as Silverblue:

```bash
sudo rpm-ostree kargs --append=systemd.ssh_auto=no
```
