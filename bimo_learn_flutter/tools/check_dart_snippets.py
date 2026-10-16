#!/usr/bin/env python3
"""Extracts complete Dart programs from the curriculum and runs `dart analyze` on them.

A ```dart block is treated as a complete file when it contains `main(`, `class `,
`import ` or `enum ` at the start of a line; other blocks are fragments and skipped.
Blocks that need Flutter (`package:flutter`) are written to a separate folder so they
can be analysed with `flutter analyze` when a Flutter SDK is available.

Usage: python3 tools/check_dart_snippets.py <dart-or-flutter-binary> [course ...] [--run]
"""
import os, re, subprocess, sys, shutil, tempfile

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app", "src", "main", "assets", "curriculum")
COMPLETE = re.compile(r"^(void main|Future<void> main|main\(|class |import |enum |abstract |sealed |mixin |extension |typedef |final class |base class |interface class )", re.M)

def blocks(path):
    lines = open(path, encoding="utf-8").read().split("\n")
    lesson, i = "?", 0
    while i < len(lines):
        l = lines[i]
        if l.startswith("@lesson "):
            lesson = l[8:].split("|")[0].strip()
        if l.strip() == "```dart":
            j = i + 1
            while lines[j].strip() != "```": j += 1
            yield lesson, i + 1, "\n".join(lines[i + 1:j])
            i = j
        i += 1

def main():
    tool = sys.argv[1]
    courses = [a for a in sys.argv[2:] if not a.startswith("--")] or ["dart"]
    flutter = "flutter" in os.path.basename(tool)
    work = tempfile.mkdtemp(prefix="bimo_snippets_")
    os.makedirs(os.path.join(work, "lib"))
    deps = "\ndependencies:\n  flutter:\n    sdk: flutter\n" if flutter else "\n"
    open(os.path.join(work, "pubspec.yaml"), "w").write("name: snippets\nenvironment:\n  sdk: ^3.5.0\n" + deps)
    open(os.path.join(work, "analysis_options.yaml"), "w").write("analyzer:\n  errors:\n    unused_local_variable: ignore\n    unused_element: ignore\n    unused_import: ignore\n    dead_code: ignore\n")
    index = {}
    n = 0
    for course in courses:
        d = os.path.join(ROOT, course)
        for f in sorted(os.listdir(d)):
            if not f.endswith(".bimo") or f == "course.bimo": continue
            for lesson, line, code in blocks(os.path.join(d, f)):
                if not COMPLETE.search(code): continue
                uses_flutter = "package:flutter" in code
                if uses_flutter != flutter and not (flutter and "package:" not in code): continue
                if re.search(r"package:(?!flutter/)", code) and not flutter: continue
                n += 1
                name = f"s{n:04d}.dart"
                index[name] = f"{course}/{f}:{line} ({lesson})"
                open(os.path.join(work, "lib", name), "w").write(code + "\n")
    print(f"checking {n} snippets in {work}")
    if flutter:
        subprocess.run([tool, "pub", "get"], cwd=work, capture_output=True)
    res = subprocess.run([tool, "analyze", "--no-fatal-warnings", "lib"], cwd=work, capture_output=True, text=True)
    out = res.stdout + res.stderr
    problems = [l for l in out.splitlines() if l.strip().startswith("error")]
    for l in problems:
        m = re.search(r"(s\d{4}\.dart):(\d+)", l)
        where = index.get(m.group(1), "?") + f" +{m.group(2)}" if m else ""
        print(where, "::", l.strip())
    if "--run" in sys.argv and not flutter:
        for name in sorted(index):
            code = open(os.path.join(work, "lib", name)).read()
            if "main(" in code and "dart:io" not in code and "stdin" not in code:
                r = subprocess.run([tool, "run", os.path.join("lib", name)], cwd=work, capture_output=True, text=True, timeout=60)
                if r.returncode != 0:
                    print("RUNTIME", index[name], r.stderr.strip().splitlines()[-1:] )
    print(f"{len(problems)} error(s)")
    shutil.rmtree(work, ignore_errors=True)
    sys.exit(1 if problems else 0)

main()
