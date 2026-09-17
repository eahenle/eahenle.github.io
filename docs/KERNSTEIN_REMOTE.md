# Kernstein Remote launcher

## Release state

`0.1.0-precontract.2` is a reviewable, deliberately non-connecting scaffold.
The verified `KERNSTEIN_CLIENT_CONTRACT` has not yet been provided. Therefore
this revision publishes **no connection defaults** and cannot start a VPN,
tunnel, Windows App, or desktop session. This prevents guessed settings from
being presented as a working release.

The intended production command remains:

```sh
curl -fsSL https://henletech.net/kernstein | sh
```

Do not promote this route as working until the Mac owner has supplied the
contract and tested the exact public artifact outside the home LAN.

## Configuration schema version 1

The local file is `~/.config/kernstein-remote/connection.json`. The launcher
also honors `XDG_CONFIG_HOME` (and the test-oriented
`KERNSTEIN_CONFIG_HOME`) as the directory containing `kernstein-remote/`.
It creates directories with umask `077` and installs the file atomically with
mode `0600`. A same-directory hard-link operation provides no-clobber creation;
if another process wins the race, its configuration is preserved and validated.

At this pre-contract stage, the only defined and consumed field is:

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `schema_version` | integer | yes | Must equal `1`. |

An initial file is consequently:

```json
{
  "schema_version": 1
}
```

The connection fields and their public/local-only classification will be added
only from `KERNSTEIN_CLIENT_CONTRACT`. Apple's `osascript` validates the file
with JavaScript's strict `JSON.parse`, then `plutil` inspects the schema. The
configuration is never sourced or evaluated as shell code. Unknown fields are
preserved but ignored so a scaffold run cannot destroy Mac-agent configuration.

## Trust and security boundary

The public script contains no credentials, private keys, reusable enrollment
keys, private endpoints, app identifiers, or speculative launch arguments.
Downloading it grants no network or desktop access. Future releases will rely
on the repository's reviewed GitHub Pages publishing path and HTTPS. A digest
served by the same site would detect accidental corruption but would not add
independent authentication, so none is claimed here.

No part of the launcher runs with `sudo`. A future contract-specific install
step may request narrowly scoped privilege only if the verified official
distribution requires it. Normal launches must remain unprivileged.

## Commands and exit status

* `--version` prints the source release without platform checks.
* `--check` validates macOS, `osascript`, `plutil`, and the local schema.
* `--status` reports readiness without making a connection.
* No argument attempts a launch; this pre-contract revision exits `78` after
  validation because launching is intentionally unavailable.
* Exit `64` means invalid command usage, `69` means an unavailable platform or
  prerequisite, and `78` means invalid/incomplete configuration.

## Deployment and rollback

This repository is the source for `henletech.net`: `_config.yml` sets that URL,
`CNAME` names the domain, and the production response is served by GitHub
Pages. GitHub Pages publishes the configured source after an approved merge.
Release `0.1.0-precontract.2` was fetched successfully from the production
`/kernstein` route after merge. No Turbify setting is involved in publishing
new versions of this path; retain the existing domain registration and DNS
settings unless the site's hosting architecture changes.

Rollback is a revert of the publishing commit. On a Mac, remove only launcher
state with:

```sh
rm -rf "$HOME/.config/kernstein-remote"
```

Review the directory first if it later contains user-created settings. This
scaffold installs no application, login item, daemon, VPN, or tunnel.

## Mac-agent validation (after the contract is incorporated)

The Mac agent should test the exact revision first, then the live route:

```sh
curl -fsSL https://henletech.net/kernstein -o /tmp/kernstein
/bin/sh -n /tmp/kernstein
/bin/sh /tmp/kernstein --version
/bin/sh /tmp/kernstein --check
curl -fsSL https://henletech.net/kernstein | /bin/sh
```

Expected for this scaffold: version and check succeed; the final invocation
clearly reports that the client contract is pending and exits `78`, with no
network enrollment or Windows App launch. A future candidate is complete only
when the Mac agent reports that the final command reaches Kernstein through the
authenticated private network from outside the home LAN.
