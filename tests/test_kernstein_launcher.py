import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
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
        self.bin.mkdir()
        self._write_command("uname", "#!/bin/sh\nprintf 'Darwin\\n'\n")
        self._write_command(
            "plutil",
            """#!/usr/bin/env python3
import json
import sys

path = sys.argv[-1]
try:
    with open(path, encoding="utf-8") as stream:
        value = json.load(stream)
except (OSError, ValueError):
    raise SystemExit(1)
if sys.argv[1] == "-lint":
    raise SystemExit(0)
if sys.argv[1:4] == ["-extract", "schema_version", "raw"]:
    schema = value.get("schema_version")
    if type(schema) is not int:
        raise SystemExit(1)
    print(schema)
    raise SystemExit(0)
raise SystemExit(2)
""",
        )

    def _write_command(self, name, body):
        path = self.bin / name
        path.write_text(body, encoding="utf-8")
        path.chmod(0o755)

    def run_launcher(self, *arguments, path=None, source=LAUNCHER, append_path=True):
        environment = os.environ.copy()
        selected_path = str(path or self.bin)
        environment["PATH"] = (
            f"{selected_path}:{environment['PATH']}" if append_path else selected_path
        )
        environment["KERNSTEIN_CONFIG_HOME"] = str(self.config_home)
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
        self.assertEqual(result.stdout.strip(), "0.1.0-precontract.1")

    def test_fresh_setup_is_restrictive_and_does_not_connect(self):
        result = self.run_launcher()
        self.assertEqual(result.returncode, 78)
        self.assertEqual(json.loads(self.config.read_text()), {"schema_version": 1})
        self.assertEqual(stat.S_IMODE(self.config.stat().st_mode), 0o600)
        self.assertIn("no network or app action was taken", result.stderr)

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

    def test_unsupported_operating_system_is_rejected(self):
        self._write_command("uname", "#!/bin/sh\nprintf 'Linux\\n'\n")
        result = self.run_launcher("--check")
        self.assertEqual(result.returncode, 69)
        self.assertIn("macOS is required", result.stderr)
        self.assertFalse(self.config.exists())

    def test_missing_plutil_is_rejected(self):
        isolated_bin = self.root / "uname only"
        isolated_bin.mkdir()
        shutil.copy2(self.bin / "uname", isolated_bin / "uname")
        # Include system utilities but shadow command lookup by invoking a shell
        # whose PATH has a deliberately absent plutil on this Linux test host.
        result = self.run_launcher("--check", path=isolated_bin, append_path=False)
        self.assertEqual(result.returncode, 69)
        self.assertIn("'plutil' was not found", result.stderr)

    def test_interrupted_download_before_final_invocation_has_no_effect(self):
        content = LAUNCHER.read_text(encoding="utf-8")
        self.assertTrue(content.endswith('main "$@"\n'))
        partial = self.root / "partial launcher"
        partial.write_text(content.removesuffix('main "$@"\n'), encoding="utf-8")
        result = self.run_launcher(source=partial)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.config.exists())

    def test_route_is_raw_shell_source(self):
        content = LAUNCHER.read_text(encoding="utf-8")
        self.assertTrue(content.startswith("#!/bin/sh\n"))
        self.assertNotIn("---\n", content[:100])
        self.assertNotIn("<html", content.lower())


if __name__ == "__main__":
    unittest.main()
