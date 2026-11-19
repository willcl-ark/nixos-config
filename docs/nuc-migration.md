# NUC migration draft

`nixosConfigurations.nuc` is an initial draft for the existing `will-NUC`.
Nothing has been built or deployed. It is not yet a complete replacement for
Debian. The host does not import the desktop `base` slice.

The private backup and inventory are on this computer at
`/home/will/nuc-backup-data/`. Read its README for capture times, verification
and exclusions. Do not add that directory or its contents to Git.

## Included in the draft

- Existing ext4/LVM filesystems and swap, addressed by UUID; no formatting.
- The existing EFI partition, with systemd-boot proposed for NixOS.
- DHCP on `eno1`, SSH, Tailscale, firmware and disk monitoring.
- Existing numeric identities for Will, Bitcoin and the media applications.
- Plex, Sonarr and Radarr using their existing state locations and media paths.
- Bitcoin Core, electrs, Tor, UPS shutdown and the existing NZBGet installation.
- NAS mount `10.0.0.130:/shared` at `/data`, using the existing NFS version 3.

The flake attribute is `nuc`; the hostname is `will-nuc` to retain the existing
tailnet naming convention. Tailscale identity restoration or re-enrollment is
still a cutover step. SSH and Plex TCP access are allowed on Ethernet; the
Sonarr/Radarr web ports are allowed only through Tailscale. This deliberately
does not reproduce every old UFW allowance. Review router forwarding and tailnet
ACLs before first boot.

## Preserve and restore

| Service | State location | UID / primary GID |
| --- | --- | --- |
| Plex | `/home/will/plex/Plex Media Server` | 998 / 998 |
| Sonarr | `/var/lib/sonarr` | 119 / 1002 |
| Radarr | `/var/lib/radarr` | 1002 / 1002 |
| Bitcoin | `/home/bitcoin/.bitcoin` | 1001 / 1001 |

Plex's NixOS `dataDir` is the parent `/home/will/plex`; its module appends
`Plex Media Server`. The old Debian symlink under `/var/lib/plexmediaserver`
is not needed. Media group GID 1002 and dataaccess GID 1004 are retained.
Plex and the Arr services need access under `/home`, so their default
`ProtectHome` restriction is disabled. Will's `homeMode` is explicitly `755`,
matching Debian; NixOS otherwise changes it to `700` and blocks traversal by
the media users. Validate NAS permissions and download
imports, including the Arr modules' user-namespace hardening, in a restore test.

Keep `/data/plex/{tv,kids_tv,movies,kids_movies,documentaries}` unchanged.
Existing downloads are under `/home/will/nzbget` and `/data/downloads`; NZBGet
uses its existing static 21.1 installation and private runtime configuration.
The media units require these mounts before starting. Restore the application
state and ownership before first activation. The backup's extracted Plex files
have private local permissions for inspection, not their final service ownership.
The ZIP/database archives do not include the actual media or downloaded files.

## Before installation

1. Rehearse restores on copies. Match the recorded application versions first;
   packages from the current nixpkgs pin may upgrade databases. Do not point a
   test instance at the production writable state or permit duplicate downloads.
2. Decide where `/nix` will live. The root LV is only 23 GiB and the volume group
   has virtually no unallocated space. The draft does not repartition, resize or
   move data. Preserve `/home` and the external Bitcoin block filesystem.
3. Check firmware Secure Boot settings, available EFI space and the proposed
   systemd-boot configuration. The old 244 MiB ext2 partition is currently
   unmounted and is intentionally not repurposed. Compare a live NixOS hardware
   scan with this manually transcribed draft before using it.
4. Preserve the SSH host private key for SOPS decryption before activation.
   The draft authorizes `~/.ssh/hetzner-temp.pub` for root, with password login
   disabled. Root administration does not require a sudo password secret. Keep
   Will's existing authorized keys if normal-user SSH access is wanted too.
5. Review `system.stateVersion` before the first installation, then keep it fixed.
6. Refresh backups at the actual cutover, establish an ongoing off-host backup
   policy, and verify services individually before retiring Debian recovery data.

## Remaining cutover work

- Confirm the electrs version/index combination: the current nixpkgs pin supplies
  0.12.0, while Debian is indexing with 0.12.1. Use nixpkgs as requested, without
  a package override. Upstream 0.12.1 also updates bindex, so do not assume a
  backwards-compatible index without checking. No live downgrade was performed.
- Rehearse restores, resolve `/nix` capacity and prepare the non-formatting
  installer procedure. Preserve the existing Tailscale identity/IP; Core's RPC
  configuration explicitly binds 100.104.49.27 and its unit checks that address.
- Decide whether to retain Soju, exit-node routing, dynamic DNS, NFS exports,
  discovery, bandwidth history and the old certificate renewal. These are not
  yet fully represented by the draft. Caddy remains disabled.
- Lightning, Nostr and DrahtBot are retired. Do not restore their enablement.
  The stopped full Lightning datadir is backed up privately; never run duplicate
  nodes with the same identity or treat an old database as a live channel backup.
- Validate the firewall, media permissions, hardware transcoding and UPS operation
  during the eventual restore test. The no-build/no-deploy restriction still holds.

Local evaluation is now authorized and passes with import-from-derivation
disabled. Build, deployment and disk installation still require a later explicit
request.

## Runtime audit and decisions, 2026-11-18

- Radarr was upgraded on Debian from 5.11.0.9244 to the pinned Nix version,
  6.4.4.10685. Its API reported no health issues and retained all 279 movies.
  The migrated database passed SQLite quick_check; fresh application-generated
  and stopped-state backups are in the private backup directory. Radarr is
  stopped again, alongside Plex and Sonarr. All three remain enabled for boot.
- Sonarr 4.0.20.3014 and Plex 1.43.5.11079-b3b13e506 already match the flake pin.
  Sonarr and Radarr use `/sonarr/` and `/radarr/` URL bases. Both use NZBGet at
  localhost:6789 with `tv` and `movies` categories; the draft now includes the existing NZBGet service. Indexer and client credentials remain in the backed-up DBs.
- NZBGet 21.1 runs as plex:plex from `/home/will/nzbget/nzbget`. Preserve its
  queue, completed/incomplete paths, CA bundle and EMail.py/Logger.py scripts.
  Downloads are not included in the off-host configuration backup.
- Nostr and DrahtBot were explicitly retired: their services are stopped and
  disabled. Do not restore their enablement from the historical `/etc` archive.
  Their source/data/backups are retained, but neither belongs in the NixOS host.
  Old Python environments will not be migrated; create flakes when needed.
  General C/C++ build tools and Python are included in the draft.
- Tailscale currently provides SSH and advertises both default routes as an
  exit node. Restoring login state alone does not configure NixOS forwarding;
  port exit-node routing explicitly if retained. Tailscale SSH is now explicit.
- Soju 0.9.0 binds specifically to 100.104.49.27:6667. Preserve that identity/IP,
  add the tailnet firewall allowance and order startup after Tailscale is ready.
  Preserve both its database and message-history files.
- Bitcoin RPC also binds to that Tailscale IP. Preserve its whitebind download
  exemption, indexes, REST access for electrs and ZMQ endpoint. Require the
  external block mount before starting Core so an absent disk cannot result in
  writes to the root filesystem. Electrs must start after Core is available.
- Core/Lightning use Tor at 127.0.0.1:9050 and Lightning uses the control port
  9051. The current bitcoin user belongs to debian-tor for control-cookie access;
  arrange the NixOS equivalent. Preserve Tor's onion identity. Lightning also
  has a hard-coded announced public address to review.
- Core, electrs and Lightning binaries use Debian's ELF loader. The draft uses
  nixpkgs for Core/electrs. Retired Lightning is a
  custom v23.11.2 build with plugins; its source is under
  `/home/bitcoin/src/lightning` at 6f9356fb9, with modified submodule revisions.
  That source tree is outside the current off-host backup. Preserve it before
  rebuilding, and reproduce or deliberately retire each plugin.
- The NUC reexports the NAS-mounted `/data` over NFS to LAN and tailnet clients.
  The draft only mounts it; determine whether clients still need the exports.
- ddclient updates Namecheap dynamic DNS. apcupsd provides actual USB UPS
  shutdown handling at 5% battery or 5 minutes remaining. UPS handling is now included; ddclient still needs a port if retained. Their
  private configuration is in the `/etc` backup.
- Review Certbot's old elec.256k1.dev DNS renewal separately from Tailscale's
  managed Electrum certificate. Its manual DNS hook and credentials are not a
  replacement for the tailnet certificate. Caddy remains disabled.
- Avahi discovery, fail2ban, local mail and vnstat need retain-or-retire decisions.
  Historical vnstat data is not in the current backup. No active containers or
  custom user timers were found.

## Tailscale secret and installer access

`secrets/nuc.yaml` is encrypted to the NUC's existing SSH Ed25519 host identity,
Will's age identity and the YubiKey recipient. The supplied `tailscale_auth_key`
decrypts locally and has the expected format; edit it with `sops secrets/nuc.yaml`.
It has not been consumed for a test enrollment. Check its expiry and any tags or
device-approval requirements before the actual installation.
The draft passes the root-only decrypted file to `services.tailscale.authKeyFile`.
Do not put the plaintext auth key in Nix expressions or Git.

The original `/etc/ssh/ssh_host_ed25519_key` must exist before first activation.
Preserve it with nixos-anywhere's `--copy-host-keys` or restore it privately before
installation. Generating a different host key will not decrypt this file; fetching
the identity after deployment would be too late. Preserve `/var/lib/tailscale`
at the final stopped-service cutover to retain the existing IP and name. A fresh
auth-key enrollment can create a different device identity.
The draft explicitly enables Tailscale SSH on startup, including fresh enrollment;
tailnet SSH policy must still authorize the resulting device and user.

nixos-anywhere can skip its disk phase with `--phases`, or use a mount-only Disko
configuration with `--disko-mode mount`. Its default disk phase destroys the
specified layout. We have not prepared or tested an installer command. Reusing
filesystems requires mounting the intended target layout before installation;
the draft's `fileSystems` options are not themselves an installer mount script.
Plan LAN SSH and console access: the stock kexec installer does not preserve the
running Tailscale session. Use the LAN address, not the tailnet SSH alias, for
that installation path. No disk operations are authorized at this stage.

References: [nixos-anywhere CLI](https://github.com/nix-community/nixos-anywhere/blob/main/docs/cli.md),
[Tailscale auth keys](https://tailscale.com/docs/features/access-control/auth-keys).

## SSH and user-job audit

Direct LAN SSH to 10.0.0.88 reached the Debian SSH server, verified its host key
against the trusted tailnet connection, and received acceptance of Will's public
key. The test timed out waiting for local SSH-agent signing, so a complete LAN
login remains to be demonstrated with the agent unlocked. The existing authorized
keys include both keys offered by the local agent. Preserve the host private key
and `/home/will/.ssh/authorized_keys`; the draft allows port 22 on Ethernet and
Tailscale. Root key login was subsequently enabled and tested successfully with
`hetzner-temp`; password login remains disabled. The draft no longer requires a
sudo password-hash file because administration can use that root key.

Only Will has an active user manager, with D-Bus and PulseAudio services. No user
timers, lingering users, custom user-unit files, root/user crontabs, at jobs,
running tmux/screen servers or detached custom applications were found. Processes
outside service units were interactive shells and a root journalctl session.
System cron entries were packaged housekeeping. There are no additional custom
user jobs to port based on this audit.

## Root access and retained services, 2026-11-19

The public key from `~/.ssh/hetzner-temp.pub` is authorized for root on Debian
and in the NixOS draft. A direct LAN login using its private key succeeded,
without a password. To test it yourself:

```sh
ssh -F ~/.ssh/config -i ~/.ssh/hetzner-temp -o IdentitiesOnly=yes -o IdentityAgent=none root@10.0.0.88
```

At first connection, verify the host key fingerprint against the existing NUC
key. Root login is `prohibit-password`, not password authentication. This LAN
access path avoids relying on Tailscale during the temporary installer boot.

Core 32.1 uses the existing `/home/bitcoin/.bitcoin/bitcoin.conf`, including RPC
credentials, whitebind, indexes, REST and maxuploadtarget=500M, outside the Nix
store. The external blocks mount is required. Electrs retains its current paths
and arguments and listens on loopback; Tailscale Serve provides 50001/plain and
50002/TLS. Tor preserves its numeric identity and onion keys. Bitcoin debug logs
rotate with SIGHUP; logrotate is allowed to access the datadir under `/home`.

UPS shutdown preserves the 5% battery/5-minute thresholds. The native NixOS
power-off hook uses a marker under `/run/apcupsd`; that directory is preserved
until shutdown finishes. Do not test power loss until the migration is ready.

NZBGet retains its static 21.1 AppDir because nixpkgs currently supplies 26.3.
It runs as plex:plex, keeps UMask 0002 and requires `/data` for its movie/TV
categories. Python3 handles the bundled scripts. Its small installation assets
are now archived in `other-state/nzbget-installation.tar.gz`.

Lightning was stopped and disabled. `lightning/final-datadir.tar.gz` is a fresh
complete archive of `/home/bitcoin/.lightning`, including wallet secrets,
databases, plugins and logs; it supersedes the earlier partial snapshot.
The original directory remains intact. Bitcoin and electrs were not restarted.

## Current mount and installer validation status

The block SSD at `/mnt/data` is a boot mount with `nofail`, not an on-demand
systemd automount. Core's explicit mount requirement prevents startup without
it. The NAS at `/data` uses `x-systemd.automount` with `nofail`, NFSv3 and a
30-second mount-attempt timeout. Access triggers mounting; an unavailable NAS
does not hold up the filesystem boot target. Media services still explicitly
require the mount, so starting them also requests it. If their startup fails
because the NAS is offline, restart those services once it is available.
Normal NFS hard-mount behaviour is retained for an outage after mounting; the
30-second timeout does not limit application I/O on an established mount.

The separate `/home` LV can be reused without formatting, but the installer
procedure has not been authored or tested. The application backup is not a
complete backup of `/home`. nixos-anywhere's `--vm-test` builds/tests a virtual
installation; it is not a report of deletions on the live NUC. A useful rehearsal
must represent the existing LVM layout with sample files and prove their survival.
Review every generated disk/mount command, omit destructive disk phases, and
resolve `/nix` storage before attempting the real installation. No installer
command is currently approved or ready to run.

## Local evaluation result

The complete NUC system derivation evaluates successfully with
`--option allow-import-from-derivation false`. No build was run. Evaluation caught
and fixed Radarr's UID1002 needing an explicit `isSystemUser = true` declaration.
Rendered units confirm block/NAS mount dependencies, runtime Bitcoin config,
loopback electrs, key-only root SSH, UPS shutdown and logrotate home access.
This does not validate boot, application restores or any disk installation steps.

The upstream [mount-only guide](https://github.com/nix-community/nixos-anywhere/blob/main/docs/howtos/disko-modes.md)
confirms that `--disko-mode mount` boots the installer, mounts existing filesystems,
installs and reboots without the formatting phase. It is still a real installation,
not a dry run. The current flake has runtime `fileSystems` definitions but no Disko
mapping of the existing partitions/LVs; that mapping and its generated mount script
must be prepared and inspected before using this workflow.

## Headless terminal profile and administrative access

The NUC imports its own small Home Manager profile for Will, not the shared
workstation base. It configures Fish vi bindings, an SSH-friendly Starship
prompt, Git/gh, htop, ripgrep, tmux and plain Neovim. No desktop environments,
mail/music clients, GUI clipboard helpers, old plugin trees or pyenv/nvm/OMF
startup hooks are imported. Neovim's optional language providers and Home Manager
MIME/font integration are disabled. Keep old dotfiles archived for reference;
do not restore the old Fish/Neovim plugin directories wholesale over this profile.
Existing managed-file conflicts are backed up with the `nuc-hm-backup` suffix.

The evaluated system boots to `multi-user.target`, with X11, the display manager
and greetd disabled. Intel graphics libraries remain for Plex transcoding. Local
console and emergency access are retained; the generic NixOS headless profile
would disable those and is intentionally not imported.

Will is in wheel, but sudo still requires a password. The separately tested
root SSH key is the password-free administration path. Root permits public-key
login and prohibits password login. No changes to live dotfiles or deployment
were made while adding this profile.
