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
`ProtectHome` restriction is disabled. Validate NAS permissions and download
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
- NZBGet, Soju, Nostr, DrahtBot, Tor onion identity, UPS handling, NFS exports,
  dynamic DNS, scheduled jobs, certificates and any remaining required services.
- Secrets provisioning, application package pins, Plex hardware transcoding and
  the full networking/firewall policy. Disabled legacy services need an explicit
  retain-or-retire decision rather than being enabled automatically.

Only static Nix parsing is permitted at this stage. Build, deployment and disk
installation require a later explicit request.
