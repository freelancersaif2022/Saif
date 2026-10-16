#!/usr/bin/env python3
"""Runs every `? output:` quiz question that contains a complete Dart program and
prints the actual output next to the option marked correct, for human review.
Usage: python3 tools/check_output_questions.py <dart-binary> [course]"""
import os, re, subprocess, sys, tempfile
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app", "src", "main", "assets", "curriculum")
dart = sys.argv[1]; course = sys.argv[2] if len(sys.argv) > 2 else "dart"
tmp = tempfile.mkdtemp()
for f in sorted(os.listdir(os.path.join(ROOT, course))):
    if not f.endswith(".bimo") or f == "course.bimo": continue
    lines = open(os.path.join(ROOT, course, f), encoding="utf-8").read().split("\n")
    lesson = "?"; i = 0
    while i < len(lines):
        l = lines[i]
        if l.startswith("@lesson "): lesson = l[8:].split("|")[0].strip()
        if l.startswith("? output:"):
            j = i + 1
            while j < len(lines) and lines[j].strip() != "```dart": j += 1
            k = j + 1
            while lines[k].strip() != "```": k += 1
            code = "\n".join(lines[j + 1:k])
            m = k + 1; correct = None
            while m < len(lines) and not lines[m].startswith("? ") and not lines[m].startswith("@lesson"):
                if lines[m].startswith("+ "): correct = lines[m][2:]
                m += 1
            if "main(" in code and "package:" not in code:
                path = os.path.join(tmp, "q.dart"); open(path, "w").write(code)
                r = subprocess.run([dart, "run", path], capture_output=True, text=True, timeout=60)
                out = (r.stdout.strip() or r.stderr.strip().splitlines()[0] if (r.stdout.strip() or r.stderr.strip()) else "").replace("\n", " ⏎ ")
                norm = lambda s: re.sub(r"[\s⏎,]+", " ", s).strip()
                flag = "  " if norm(out) == norm(correct or "") else "??"
                print(f"{flag} {lesson}: expected [{correct}] got [{out}]")
            i = k
        i += 1
