# Kernstein Remote launcher

## Release state

Release `0.2.0` implements the verified Mac-to-Kernstein client contract. The
production command validates the private path, starts an authenticated SSH
tunnel from Mac loopback TCP/3389 to Kernstein loopback TCP/3389, and opens the
persistent Windows App connection:

```sh
curl -fsSL https://henletech.net/kernstein | sh
```

Windows App opens its Connection Center. Connect to the saved PC named
`Kernstein Desktop`; its endpoint remains `127.0.0.1:3389`, so reconnects use
the launcher-managed tunnel rather than exposing RDP directly.

## Verified connection contract

The launcher pins the non-secret facts verified on September 17, 2026:

| Component | Required value |
| --- | --- |
| Tailscale peer | `kernstein.tail83f91c.ts.net` |
| Tailnet suffix | `tail83f91c.ts.net` |
| SSH endpoint and user | `kernstein.tail83f91c.ts.net:22`, `graf` |
| SSH host-key alias | `kernstein` |
| SSH host-key fingerprint | `SHA256:pVBg+iXWeVA2Sk2p9nD8PTFp++gDIGJzICIgToQND44` |
| SSH identity | `~/.ssh/id_ed25519_kernstein` |
| SSH known-hosts file | `~/.ssh/known_hosts_kernstein` |
| Tunnel | `127.0.0.1:3389` to Kernstein `127.0.0.1:3389` |
| Saved Windows App PC | `Kernstein Desktop` at `127.0.0.1:3389` |
| RDP TLS fingerprint | `9A:3E:ED:A6:40:B8:F8:58:9B:48:60:1D:64:8F:22:A8:AB:31:47:FE:61:28:FA:41:7C:D0:D4:DC:68:01:C2:D5` |

Live validation confirmed Tailscale and ordinary OpenSSH end to end from an
off-LAN Mac, then negotiated RDP protocol 2 through the loopback tunnel and
matched the pinned RDP TLS certificate. Kernstein's RDP listener is rejected by
its host firewall on the Tailscale interface; the launcher uses the established
SSH channel and remote loopback instead. Tailscale SSH, Funnel, Serve, subnet
routing, exit-node advertisement, and public port forwarding remain disabled.

## Local prerequisites

This release reuses deliberately provisioned local credentials; it never
downloads or embeds secrets. Before launch, the Mac must already have:

- the official Tailscale client running in the intended personal tailnet;
- the dedicated passphrase-protected SSH key authorized on Kernstein and loaded
  through the macOS agent/Keychain;
- the dedicated identity `~/.ssh/id_ed25519_kernstein` and the single verified
  `kernstein` entry in `~/.ssh/known_hosts_kernstein`;
- Microsoft Windows App with the persistent saved PC `Kernstein Desktop`;
- macOS tools `awk`, `lsof`, `open`, `osascript`, `plutil`, `python3`, `shlock`,
  `sqlite3`, `ssh`, and `ssh-keygen`; Kernstein also provides `python3` for the
  remote readiness probe.

The launcher checks these boundaries before connecting. Every SSH invocation
uses `-F /dev/null` plus explicit endpoint, identity, host-key, authentication,
and proxy options, so unrelated user configuration, identities, port forwards,
proxy jumps, and proxy commands cannot be inherited. It will not fall back to
passwords, a different SSH endpoint, an unpinned host key, or direct RDP. It
also reads Windows App's connection database in read-only mode and requires
exactly one `Kernstein Desktop` entry targeting `127.0.0.1:3389`. Before
reporting readiness it negotiates RDP TLS against the remote loopback listener
and verifies the pinned certificate; after opening or reusing the tunnel it
repeats that verification through the forwarded local endpoint.

## Configuration and state

The local configuration is
`~/.config/kernstein-remote/connection.json`. The launcher also honors
`XDG_CONFIG_HOME` and the test-only `KERNSTEIN_CONFIG_HOME`. It creates the
directory with umask `077`, atomically installs the file with mode `0600`, and
never overwrites a file created concurrently.

Schema version 1 currently consumes only:

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `schema_version` | integer | yes | Must equal `1`. |

The verified security-critical connection values are pinned in the reviewed
public launcher instead of being silently overridden by local JSON. Unknown
JSON fields are preserved but ignored. Apple's `osascript` enforces strict JSON
with JavaScript's `JSON.parse`; `plutil` then checks the integer schema.

Runtime state is stored under `~/.local/state/kernstein-remote/` (or
`XDG_STATE_HOME`). The SSH control socket there identifies only a tunnel
started by this launcher. A PID lock created atomically by macOS `shlock`
serializes start, stop, and restart operations so concurrent invocations cannot
unlink a live control socket or orphan a detached tunnel. Locks abandoned by a
crash or forced restart are recovered automatically.

## Commands and exit status

When passing an option through a pipe, use `sh -s --`:

```sh
curl -fsSL https://henletech.net/kernstein | sh -s -- --check
curl -fsSL https://henletech.net/kernstein | sh -s -- --status
curl -fsSL https://henletech.net/kernstein | sh -s -- --start
curl -fsSL https://henletech.net/kernstein | sh -s -- --stop
```

- No option validates the live Tailscale and SSH path, starts or reuses the
  tunnel, and opens Windows App.
- `--check` verifies readiness without starting a tunnel or opening an app.
- `--status` verifies readiness and reports whether the managed tunnel runs.
- `--start`, `--stop`, and `--restart` manage only this launcher's SSH tunnel.
- `--version` prints the release without platform or network checks.
- Exit `64` means invalid usage, `69` means a prerequisite or live connection is
  unavailable, and `78` means local configuration or the pinned contract is
  invalid.

## Trust, deployment, and rollback

The public script contains no credentials, private keys, enrollment tokens,
cookies, or reusable authentication material. It requires no `sudo`, does not
alter Tailscale enrollment, and does not modify SSH or Windows App settings.
The repository's reviewed GitHub Pages path publishes `/kernstein` after merge.

Stop the managed tunnel before removing launcher state:

```sh
curl -fsSL https://henletech.net/kernstein | sh -s -- --stop
rm -rf "$HOME/.config/kernstein-remote" "$HOME/.local/state/kernstein-remote"
```

Review both directories first if they later contain user-created settings. This
does not remove Tailscale, Windows App, the dedicated SSH identity, the pinned
known-hosts file, or the saved Windows App PC.

## Release validation

Validate the exact candidate, then the published artifact:

```sh
curl -fsSL https://henletech.net/kernstein -o /tmp/kernstein
/bin/sh -n /tmp/kernstein
/bin/sh /tmp/kernstein --version
/bin/sh /tmp/kernstein --check
/bin/sh /tmp/kernstein --start
curl -fsSL https://henletech.net/kernstein | /bin/sh
```

A release is operational only after the exact public artifact starts the tunnel
from outside the home LAN, an RDP negotiation through `127.0.0.1:3389` matches
the pinned certificate, and the user confirms the saved desktop reconnects in
Windows App. Speaker playback remains a separate user-visible check; microphone
and unrelated device redirection stay disabled.
