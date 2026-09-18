import json
import os
from pathlib import Path
import plistlib
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = ROOT / "kernstein"


class KernsteinLauncherTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="kernstein test ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.bin = self.root / "mock bin"
        self.config_home = self.root / "config home"
        self.state_home = self.root / "state home"
        self.home = self.root / "home"
        self.windows_app = self.root / "Windows App.app"
        self.windows_data = self.root / "Windows App data.sqlite"
        self.tunnel_marker = self.root / "tunnel running"
        self.open_log = self.root / "open log"
        self.ssh_log = self.root / "ssh log"
        self.rdp_log = self.root / "rdp log"
        self.bin.mkdir()
        (self.home / ".ssh").mkdir(parents=True)
        self.windows_app.mkdir()
        self.windows_data.touch()
        (self.home / ".ssh" / "id_ed25519_kernstein").write_text(
            "test fixture, not a private key\n", encoding="utf-8"
        )
        (self.home / ".ssh" / "known_hosts_kernstein").write_text(
            "kernstein ssh-ed25519 test-public-key\n", encoding="utf-8"
        )
        self._write_command("uname", "#!/bin/sh\nprintf 'Darwin\\n'\n")
        self._write_command("lsof", "#!/bin/sh\nexit 1\n")
        self._write_command(
            "open",
            "#!/bin/sh\nprintf '%s\\n' \"$*\" >>\"$KERNSTEIN_MOCK_OPEN_LOG\"\n",
        )
        self._write_command("tailscale", "#!/bin/sh\nexit 0\n")
        self._write_command("sqlite3", "#!/bin/sh\nprintf '1|1\\n'\n")
        self._write_command(
            "python3",
            """#!/bin/sh
printf '%s\n' "$*" >>"$KERNSTEIN_MOCK_RDP_LOG"
cat >/dev/null
exit 0
""",
        )
        self._write_command(
            "plutil",
            """#!/usr/bin/env python3
import json
import plistlib
import sys

path = sys.argv[-1]
try:
    with open(path, "rb") as stream:
        contents = stream.read()
    try:
        value = json.loads(contents)
    except (UnicodeDecodeError, ValueError):
        value = plistlib.loads(contents)
except (OSError, ValueError):
    raise SystemExit(1)
if sys.argv[1:5] == ["-convert", "json", "-o", "-"]:
    print(json.dumps(value))
    raise SystemExit(0)
if sys.argv[1:6] == ["-extract", "schema_version", "raw", "-expect", "integer"]:
    schema = value.get("schema_version")
    if type(schema) is not int:
        raise SystemExit(1)
    print(schema)
    raise SystemExit(0)
raise SystemExit(2)
""",
        )
        self._write_command(
            "osascript",
            """#!/usr/bin/env python3
import json
import sys

try:
    value = json.load(sys.stdin)
except (UnicodeDecodeError, ValueError):
    raise SystemExit(1)
if not isinstance(value, dict):
    raise SystemExit(1)
""",
        )
        self._write_command(
            "ssh",
            """#!/bin/sh
printf '%s\\n' "$*" >>"$KERNSTEIN_MOCK_SSH_LOG"
case " $* " in
  *" -O check "*)
    test -f "$KERNSTEIN_MOCK_TUNNEL"
    ;;
  *" -O exit "*)
    rm -f "$KERNSTEIN_MOCK_TUNNEL"
    ;;
  *" -fN "*)
    : >"$KERNSTEIN_MOCK_TUNNEL"
    ;;
  *)
    exit 0
    ;;
esac
""",
        )
        self._write_command(
            "ssh-keygen",
            """#!/bin/sh
case "$1" in
  -F)
    printf '# Host kernstein found: line 1\\n'
    printf 'kernstein ssh-ed25519 test-public-key\\n'
    ;;
  -lf)
    printf '256 SHA256:pVBg+iXWeVA2Sk2p9nD8PTFp++gDIGJzICIgToQND44 fixture (ED25519)\\n'
    ;;
  *) exit 2 ;;
esac
""",
        )
        self._write_command(
            "shlock",
            """#!/usr/bin/env python3
import os
import sys

path = sys.argv[sys.argv.index("-f") + 1]
owner = sys.argv[sys.argv.index("-p") + 1]
try:
    with open(path, encoding="utf-8") as stream:
        existing_owner = int(stream.read().strip())
    os.kill(existing_owner, 0)
except (OSError, ValueError):
    try:
        os.unlink(path)
    except FileNotFoundError:
        pass
else:
    raise SystemExit(1)

descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
    stream.write(f"{owner}\\n")
""",
        )

    def _write_command(self, name, body):
        path = self.bin / name
        body = body.replace(
            "#!/usr/bin/env python3\n", f"#!{sys.executable}\n", 1
        )
        path.write_text(body, encoding="utf-8")
        path.chmod(0o755)

    def run_launcher(self, *arguments, path=None, source=LAUNCHER, append_path=True):
        environment = os.environ.copy()
        selected_path = str(path or self.bin)
        environment["PATH"] = (
            f"{selected_path}:{environment['PATH']}" if append_path else selected_path
        )
        environment["HOME"] = str(self.home)
        environment["KERNSTEIN_CONFIG_HOME"] = str(self.config_home)
        environment["KERNSTEIN_STATE_HOME"] = str(self.state_home)
        environment["KERNSTEIN_WINDOWS_APP_PATH"] = str(self.windows_app)
        environment["KERNSTEIN_WINDOWS_DATA_PATH"] = str(self.windows_data)
        environment["KERNSTEIN_MOCK_TUNNEL"] = str(self.tunnel_marker)
        environment["KERNSTEIN_MOCK_OPEN_LOG"] = str(self.open_log)
        environment["KERNSTEIN_MOCK_SSH_LOG"] = str(self.ssh_log)
        environment["KERNSTEIN_MOCK_RDP_LOG"] = str(self.rdp_log)
        return subprocess.run(
            ["/bin/sh", str(source), *arguments],
            check=False,
            capture_output=True,
            text=True,
            env=environment,
        )

    @property
    def config(self):
        return self.config_home / "kernstein-remote" / "connection.json"

    def test_version_requires_no_macos_tools(self):
        result = self.run_launcher("--version", path=self.root / "empty")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "0.2.0")

    def test_fresh_launch_initializes_config_starts_tunnel_and_opens_app(self):
        result = self.run_launcher()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.config.read_text()), {"schema_version": 1})
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertTrue(self.tunnel_marker.exists())
        self.assertFalse(
            (self.state_home / "kernstein-remote" / "tunnel.lock").exists()
        )
        self.assertIn(str(self.windows_app), self.open_log.read_text())
        self.assertIn("Windows App opened", result.stderr)

    def test_check_verifies_without_starting_or_opening(self):
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.tunnel_marker.exists())
        self.assertFalse(self.open_log.exists())
        self.assertIn("host identity", result.stderr)

    def test_repeat_check_preserves_existing_configuration(self):
        self.config.parent.mkdir(parents=True)
        original = b'{"schema_version":1,"future_local_value":"keep me"}\n'
        self.config.write_bytes(original)
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_bytes(), original)

    def test_failed_initialization_does_not_leave_partial_configuration(self):
        self.config_home.write_text("blocks directory creation", encoding="utf-8")
        result = self.run_launcher()
        self.assertEqual(result.returncode, 78)
        self.assertIn("could not create configuration directory", result.stderr)
        self.assertTrue(self.config_home.is_file())

    def test_concurrent_configuration_creation_is_not_overwritten(self):
        self._write_command(
            "ln",
            """#!/bin/sh
printf '{"schema_version":1,"created_by":"other process"}\\n' >"$2"
exit 1
""",
        )
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(self.config.read_text()),
            {"schema_version": 1, "created_by": "other process"},
        )
        self.assertIn("preserving it", result.stderr)

    def test_invalid_json_and_schema_are_rejected(self):
        self.config.parent.mkdir(parents=True)
        self.config.write_text("not json", encoding="utf-8")
        invalid = self.run_launcher("--check")
        self.assertEqual(invalid.returncode, 78)
        self.assertIn("not valid JSON", invalid.stderr)

        self.config.write_text('{"schema_version":2}', encoding="utf-8")
        wrong_schema = self.run_launcher("--check")
        self.assertEqual(wrong_schema.returncode, 78)
        self.assertIn("unsupported schema_version", wrong_schema.stderr)

    def test_non_integer_schema_is_rejected(self):
        self.config.parent.mkdir(parents=True)
        self.config.write_text('{"schema_version":"1"}', encoding="utf-8")
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 78)
        self.assertIn("missing integer schema_version", result.stderr)

    def test_non_json_property_lists_are_rejected(self):
        self.config.parent.mkdir(parents=True)
        fixtures = {
            "xml": plistlib.dumps({"schema_version": 1}, fmt=plistlib.FMT_XML),
            "binary": plistlib.dumps(
                {"schema_version": 1}, fmt=plistlib.FMT_BINARY
            ),
            "openstep": b'{ "schema_version" = 1; }\n',
            "comment": b'{ /* relaxed plist syntax */ "schema_version": 1 }\n',
            "trailing comma": b'{ "schema_version": 1, }\n',
        }
        for name, contents in fixtures.items():
            with self.subTest(name=name):
                self.config.write_bytes(contents)
                result = self.run_launcher("--check")
                self.assertEqual(result.returncode, 78)
                self.assertIn("not valid JSON", result.stderr)

    def test_unsupported_operating_system_is_rejected(self):
        self._write_command("uname", "#!/bin/sh\nprintf 'Linux\\n'\n")
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 69)
        self.assertIn("macOS is required", result.stderr)
        self.assertFalse(self.config.exists())

    def test_missing_plutil_is_rejected(self):
        isolated_bin = self.root / "without plutil"
        isolated_bin.mkdir()
        for command in (
            "lsof",
            "open",
            "osascript",
            "ssh",
            "ssh-keygen",
            "tailscale",
            "uname",
        ):
            shutil.copy2(self.bin / command, isolated_bin / command)
        shutil.copyfile(shutil.which("awk"), isolated_bin / "awk")
        (isolated_bin / "awk").chmod(0o755)
        result = self.run_launcher("--check", path=isolated_bin, append_path=False)
        self.assertEqual(result.returncode, 69)
        self.assertIn("'plutil' was not found", result.stderr)

    def test_missing_osascript_is_rejected(self):
        isolated_bin = self.root / "without osascript"
        isolated_bin.mkdir()
        for command in (
            "lsof",
            "open",
            "plutil",
            "ssh",
            "ssh-keygen",
            "tailscale",
            "uname",
        ):
            shutil.copy2(self.bin / command, isolated_bin / command)
        shutil.copyfile(shutil.which("awk"), isolated_bin / "awk")
        (isolated_bin / "awk").chmod(0o755)
        result = self.run_launcher("--check", path=isolated_bin, append_path=False)
        self.assertEqual(result.returncode, 69)
        self.assertIn("'osascript' was not found", result.stderr)

    def test_failed_authenticated_ssh_is_rejected(self):
        self._write_command(
            "ssh",
            "#!/bin/sh\nexit 1\n",
        )
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 69)
        self.assertIn("authenticated OpenSSH access", result.stderr)

    def test_unreachable_tailnet_peer_is_rejected(self):
        self._write_command("tailscale", "#!/bin/sh\nexit 1\n")
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 69)
        self.assertIn("not reachable through", result.stderr)

    def test_unavailable_remote_rdp_is_rejected(self):
        self._write_command(
            "ssh",
            """#!/bin/sh
case " $* " in
  *" python3 - 127.0.0.1 3389 "*) exit 1 ;;
  *) exit 0 ;;
esac
""",
        )
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 69)
        self.assertIn("RDP listener or pinned TLS certificate", result.stderr)

    def test_missing_or_misdirected_saved_windows_pc_is_rejected(self):
        for name, contract in (("missing", "0|0"), ("wrong endpoint", "1|0")):
            with self.subTest(name=name):
                self._write_command(
                    "sqlite3", f"#!/bin/sh\nprintf '{contract}\\n'\n"
                )
                result = self.run_launcher("--check")
                self.assertEqual(result.returncode, 78)
                self.assertIn("must exist exactly once at 127.0.0.1:3389", result.stderr)

    def test_unexpected_host_key_fingerprint_is_rejected(self):
        self._write_command(
            "ssh-keygen",
            """#!/bin/sh
case "$1" in
  -F) printf 'kernstein ssh-ed25519 test-public-key\\n' ;;
  -lf) printf '256 SHA256:wrong fixture (ED25519)\\n' ;;
  *) exit 2 ;;
esac
""",
        )
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 78)
        self.assertIn("host-key fingerprint mismatch", result.stderr)

    def test_additional_host_key_is_rejected(self):
        self._write_command(
            "ssh-keygen",
            """#!/bin/sh
case "$1" in
  -F)
    printf 'kernstein ssh-ed25519 expected-public-key\\n'
    printf 'kernstein ssh-ed25519 additional-public-key\\n'
    ;;
  -lf) printf '256 SHA256:pVBg+iXWeVA2Sk2p9nD8PTFp++gDIGJzICIgToQND44 fixture (ED25519)\\n' ;;
  *) exit 2 ;;
esac
""",
        )
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 78)
        self.assertIn("exactly one key", result.stderr)

    def test_ssh_ignores_config_proxies_and_inherited_identities(self):
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.ssh_log.read_text()
        self.assertIn("-F /dev/null", calls)
        self.assertIn(f"-o IdentityFile={self.home}/.ssh/id_ed25519_kernstein", calls)
        self.assertNotIn("IdentityFile=none", calls)
        self.assertNotIn(" -i ", f" {calls} ")
        self.assertIn("-o ProxyCommand=none", calls)
        self.assertIn("-o ProxyJump=none", calls)
        self.assertIn("graf@kernstein.tail83f91c.ts.net", calls)
        self.assertNotIn(" -G ", f" {calls} ")
        self.assertEqual(
            calls.count("-L 127.0.0.1:3389:127.0.0.1:3389"), 1
        )

    def test_existing_operation_lock_prevents_concurrent_start(self):
        lock = self.state_home / "kernstein-remote" / "tunnel.lock"
        lock.parent.mkdir(parents=True)
        lock.write_text(f"{os.getpid()}\n", encoding="utf-8")
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 69)
        self.assertIn("another tunnel operation is in progress", result.stderr)
        self.assertFalse(self.tunnel_marker.exists())

    def test_abandoned_operation_lock_is_recovered(self):
        lock = self.state_home / "kernstein-remote" / "tunnel.lock"
        lock.parent.mkdir(parents=True)
        lock.write_text("2147483647\n", encoding="utf-8")
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.tunnel_marker.exists())
        self.assertFalse(lock.exists())

    def test_stop_closes_launcher_managed_tunnel(self):
        self.tunnel_marker.touch()
        self.windows_app.rmdir()
        self._write_command("tailscale", "#!/bin/sh\nexit 1\n")
        result = self.run_launcher("--stop")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.tunnel_marker.exists())
        self.assertIn("tunnel stopped", result.stderr)

    def test_failed_forwarded_rdp_verification_stops_tunnel(self):
        self._write_command("python3", "#!/bin/sh\ncat >/dev/null\nexit 1\n")
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 69)
        self.assertIn("failed pinned TLS verification", result.stderr)
        self.assertFalse(self.tunnel_marker.exists())

    def test_failed_tunnel_cleanup_preserves_control_socket(self):
        control_socket = self.state_home / "kernstein-remote" / "tunnel.sock"
        self._write_command("python3", "#!/bin/sh\ncat >/dev/null\nexit 1\n")
        self._write_command(
            "ssh",
            """#!/bin/sh
case " $* " in
  *" -O check "*) test -f "$KERNSTEIN_MOCK_TUNNEL" ;;
  *" -O exit "*) exit 1 ;;
  *" -fN "*)
    : >"$KERNSTEIN_MOCK_TUNNEL"
    : >"$KERNSTEIN_STATE_HOME/kernstein-remote/tunnel.sock"
    ;;
  *) exit 0 ;;
esac
""",
        )
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 69)
        self.assertIn("cleanup failed; control socket preserved", result.stderr)
        self.assertTrue(self.tunnel_marker.exists())
        self.assertTrue(control_socket.exists())

    def test_occupied_local_port_prevents_start(self):
        control_socket = self.state_home / "kernstein-remote" / "tunnel.sock"
        control_socket.parent.mkdir(parents=True)
        control_socket.touch()
        self._write_command("lsof", "#!/bin/sh\nexit 0\n")
        result = self.run_launcher("--start")
        self.assertEqual(result.returncode, 69)
        self.assertIn("local TCP port 3389 is already in use", result.stderr)
        self.assertTrue(control_socket.exists())

    def test_interrupted_download_before_final_invocation_has_no_effect(self):
        content = LAUNCHER.read_text(encoding="utf-8")
        self.assertTrue(content.endswith('main "$@"\n'))
        partial = self.root / "partial launcher"
        partial.write_text(content.removesuffix('main "$@"\n'), encoding="utf-8")
        result = self.run_launcher(source=partial)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.config.exists())
        self.assertFalse(self.tunnel_marker.exists())

    def test_route_is_raw_shell_source(self):
        content = LAUNCHER.read_text(encoding="utf-8")
        self.assertTrue(content.startswith("#!/bin/sh\n"))
        self.assertNotIn("---\n", content[:100])
        self.assertNotIn("<html", content.lower())


if __name__ == "__main__":
    unittest.main()
