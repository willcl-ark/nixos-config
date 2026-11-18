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
| Bitcoin, not yet enabled | `/home/bitcoin/.bitcoin` | 1001 / 1001 |

Plex's NixOS `dataDir` is the parent `/home/will/plex`; its module appends
`Plex Media Server`. The old Debian symlink under `/var/lib/plexmediaserver`
is not needed. Media group GID 1002 and dataaccess GID 1004 are retained.
Plex and the Arr services need access under `/home`, so their default
`ProtectHome` restriction is disabled. Will's `homeMode` is explicitly `755`,
matching Debian; NixOS otherwise changes it to `700` and blocks traversal by
the media users. Validate NAS permissions and download
imports, including the Arr modules' user-namespace hardening, in a restore test.

Keep `/data/plex/{tv,kids_tv,movies,kids_movies,documentaries}` unchanged.
Existing downloads are under `/home/will/nzbget`; NZBGet itself is not yet ported.
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
4. Provision `/var/lib/nuc-secrets/will-password` as a root-only file containing
   Will's password hash. Restore `/home/will/.ssh/authorized_keys`, or provision
   a reviewed public key, and test administrative access. Private keys and
   password hashes do not belong in the Nix store. Retain password-required sudo.
5. Review `system.stateVersion` before the first installation, then keep it fixed.
6. Refresh backups at the actual cutover, establish an ongoing off-host backup
   policy, and verify services individually before retiring Debian recovery data.

## Still to port

- Bitcoin Core, electrs, Lightning and their exact versions/configuration. Keep
  Core datadir `/home/bitcoin/.bitcoin` separate from blocksdir
  `/mnt/data/bitcoin/.bitcoin`. Preserve whitebind and its download permissions,
  the upload target, log rotation and the tailnet-only Electrum endpoints.
- Lightning wallet/plugin recovery and secrets. Never start two nodes with the
  same identity. A historical database backup is not a live channel backup.
- Tailscale Serve on 50001/plain and 50002/TLS; the custom Caddy updater is
  currently retained but its service is disabled.
- NZBGet, Soju, Tor onion identity, UPS handling, NFS exports,
  dynamic DNS, scheduled jobs, certificates and any remaining required services.
- Secrets provisioning, application package pins, Plex hardware transcoding and
  the full networking/firewall policy. Disabled legacy services need an explicit
  retain-or-retire decision rather than being enabled automatically.

Only static Nix parsing is permitted at this stage. Build, deployment and disk
installation require a later explicit request.

## Runtime audit and decisions, 2026-11-18

- Radarr was upgraded on Debian from 5.11.0.9244 to the pinned Nix version,
  6.4.4.10685. Its API reported no health issues and retained all 279 movies.
  The migrated database passed SQLite quick_check; fresh application-generated
  and stopped-state backups are in the private backup directory. Radarr is
  stopped again, alongside Plex and Sonarr. All three remain enabled for boot.
- Sonarr 4.0.20.3014 and Plex 1.43.5.11079-b3b13e506 already match the flake pin.
  Sonarr and Radarr use `/sonarr/` and `/radarr/` URL bases. Both use NZBGet at
  localhost:6789 with `tv` and `movies` categories; NZBGet must be ported before
  downloads work. Indexer and client credentials remain in the backed-up DBs.
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
  port the exit-node routing settings and SSH preference explicitly if retained.
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
- Core, electrs and Lightning binaries use Debian's ELF loader. Their backups
  are recovery artifacts, not directly usable NixOS packages. Lightning is a
  custom v23.11.2 build with plugins; its source is under
  `/home/bitcoin/src/lightning` at 6f9356fb9, with modified submodule revisions.
  That source tree is outside the current off-host backup. Preserve it before
  rebuilding, and reproduce or deliberately retire each plugin.
- The NUC reexports the NAS-mounted `/data` over NFS to LAN and tailnet clients.
  The draft only mounts it; determine whether clients still need the exports.
- ddclient updates Namecheap dynamic DNS. apcupsd provides actual USB UPS
  shutdown handling at 5% battery or 5 minutes remaining. Both need ports if
  retained; their private configuration is in the `/etc` backup.
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
Tailscale, prohibits root login and requires a password for sudo. The sudo password
hash file is still an explicit provisioning prerequisite, separate from Tailscale.

Only Will has an active user manager, with D-Bus and PulseAudio services. No user
timers, lingering users, custom user-unit files, root/user crontabs, at jobs,
running tmux/screen servers or detached custom applications were found. Processes
outside service units were interactive shells and a root journalctl session.
System cron entries were packaged housekeeping. There are no additional custom
user jobs to port based on this audit.
