#!/usr/bin/env python3
# Reads manifest.toml so install.sh has exactly one source of truth for
# packages/entries/hooks instead of a second, hand-maintained copy that
# silently drifts from the manifest (the bug this file exists to close).
#
# Usage:
#   manifest.py packages   [--enable a,b] [--disable c,d]  -> one package per line
#   manifest.py entries    [--enable a,b] [--disable c,d]  -> "component\tsrc\tdest" per line
#   manifest.py hooks <post_package|post_install|post_update> [--enable a,b] [--disable c,d]
#   manifest.py components                                 -> "name\tdefault(0|1)" per line, all components
#   manifest.py enabled    [--enable a,b] [--disable c,d]  -> one enabled component name per line

import sys
import tomllib
from pathlib import Path

MANIFEST = Path(__file__).resolve().parent.parent / "manifest.toml"


def enabled_components(manifest: dict, enable: set[str], disable: set[str]) -> list[dict]:
    comps = manifest.get("components", [])
    known = {c["name"] for c in comps}
    unknown = (enable | disable) - known
    if unknown:
        print(f"unknown component(s): {', '.join(sorted(unknown))}", file=sys.stderr)
        sys.exit(1)
    return [
        c
        for c in comps
        if (c.get("default", False) or c["name"] in enable) and c["name"] not in disable
    ]


def cmd_packages(manifest: dict, enable: set[str], disable: set[str]) -> None:
    seen: set[str] = set()
    for pkg in manifest.get("packages", []):
        if pkg not in seen:
            seen.add(pkg)
            print(pkg)
    for comp in enabled_components(manifest, enable, disable):
        for pkg in comp.get("packages", []):
            if pkg not in seen:
                seen.add(pkg)
                print(pkg)


def cmd_entries(manifest: dict, enable: set[str], disable: set[str]) -> None:
    for comp in enabled_components(manifest, enable, disable):
        for entry in comp.get("entries", []):
            print(f"{comp['name']}\t{entry['src']}\t{entry['dest']}")


def cmd_hooks(manifest: dict, enable: set[str], disable: set[str], kind: str) -> None:
    for hook in manifest.get(kind, []):
        print(hook)
    for comp in enabled_components(manifest, enable, disable):
        for hook in comp.get(kind, []):
            print(hook)


def cmd_components(manifest: dict) -> None:
    for comp in manifest.get("components", []):
        print(f"{comp['name']}\t{1 if comp.get('default', False) else 0}")


def cmd_enabled(manifest: dict, enable: set[str], disable: set[str]) -> None:
    for comp in enabled_components(manifest, enable, disable):
        print(comp["name"])


def main() -> None:
    args = sys.argv[1:]
    if not args:
        print("usage: manifest.py <packages|entries|hooks> ...", file=sys.stderr)
        sys.exit(1)

    action = args[0]
    rest = args[1:]

    enable: set[str] = set()
    if "--enable" in rest:
        i = rest.index("--enable")
        enable = {n.strip() for n in rest[i + 1].split(",") if n.strip()}
        del rest[i : i + 2]

    disable: set[str] = set()
    if "--disable" in rest:
        i = rest.index("--disable")
        disable = {n.strip() for n in rest[i + 1].split(",") if n.strip()}
        del rest[i : i + 2]

    manifest = tomllib.loads(MANIFEST.read_text())

    if action == "packages":
        cmd_packages(manifest, enable, disable)
    elif action == "entries":
        cmd_entries(manifest, enable, disable)
    elif action == "hooks":
        if not rest:
            print("usage: manifest.py hooks <post_package|post_install|post_update>", file=sys.stderr)
            sys.exit(1)
        cmd_hooks(manifest, enable, disable, rest[0])
    elif action == "components":
        cmd_components(manifest)
    elif action == "enabled":
        cmd_enabled(manifest, enable, disable)
    else:
        print(f"unknown action: {action}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
