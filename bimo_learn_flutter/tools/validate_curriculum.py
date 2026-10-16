#!/usr/bin/env python3
"""Validates the Bimo curriculum in app/src/main/assets/curriculum.

Checks (independent of the Kotlin parser, so both must agree):
  * every lesson has a non-trivial body, learning objectives, a summary and at least one code block
  * every quiz has 5-15 well-formed questions with explanations
  * lesson ids and question prompts are unique
  * no placeholder text
Usage: python3 tools/validate_curriculum.py [--stats]
"""
import os, re, sys

ROOT = os.path.join(os.path.dirname(__file__), "..", "app", "src", "main", "assets", "curriculum")
PLACEHOLDERS = re.compile(r"\b(TODO|TBD|lorem ipsum|placeholder text|coming soon)\b", re.I)
errors, stats = [], {"lessons": 0, "questions": 0, "words": 0, "code_blocks": 0}
seen_ids = set()

def err(msg):
    errors.append(msg)

def check_questions(lines, owner, minimum=5, maximum=15):
    qs, cur = [], None
    in_code = False
    for line in lines:
        if line.strip().startswith("```"):
            in_code = not in_code
            if cur is not None: cur["code"] = True
            continue
        if in_code: continue
        if line.startswith("? "):
            cur = {"head": line, "plus": 0, "minus": 0, "eq": 0, "order": 0, "expl": 0, "code": False}
            qs.append(cur)
        elif cur is None:
            if line.strip() and not line.strip().startswith("//"): err(f"{owner}: text before first question: {line!r}")
        elif line.startswith("+ "): cur["plus"] += 1
        elif line.startswith("- "): cur["minus"] += 1
        elif line.startswith("= "): cur["eq"] += 1
        elif line.startswith("~ "): cur["order"] += 1
        elif line.startswith("> "): cur["expl"] += 1
    if not (minimum <= len(qs) <= maximum):
        err(f"{owner}: {len(qs)} questions (expected {minimum}-{maximum})")
    prompts = set()
    for q in qs:
        kind = q["head"][2:].split(":")[0].strip()
        prompt = q["head"].split(":", 1)[1].strip() if ":" in q["head"] else ""
        if not prompt: err(f"{owner}: empty prompt")
        key = (prompt, q["code"])
        if prompt in prompts and not q["code"]: err(f"{owner}: duplicate prompt {prompt!r}")
        prompts.add(prompt)
        if q["expl"] == 0: err(f"{owner}: missing explanation for {prompt!r}")
        if kind in ("mcq", "output", "scenario"):
            if q["plus"] != 1 or q["minus"] < 1: err(f"{owner}: choice question needs exactly one '+' and some '-': {prompt!r}")
        elif kind == "tf":
            if q["eq"] != 1: err(f"{owner}: tf needs '= true|false': {prompt!r}")
        elif kind == "fill":
            if q["eq"] < 1: err(f"{owner}: fill needs '=': {prompt!r}")
            if "___" not in prompt: err(f"{owner}: fill prompt should contain ___: {prompt!r}")
        elif kind == "order":
            if q["order"] < 2: err(f"{owner}: order needs 2+ '~' lines: {prompt!r}")
        else:
            err(f"{owner}: unknown type {kind!r}")
    stats["questions"] += len(qs)
    return len(qs)

def check_body(body, lid, is_project):
    text = "\n".join(body)
    words = len(re.findall(r"[A-Za-z]+", text))
    stats["words"] += words
    code_blocks = len(re.findall(r"^\s*```[a-z]+", text, re.M))
    stats["code_blocks"] += code_blocks
    min_words = 450 if is_project else 280
    if words < min_words: err(f"{lid}: only {words} words (min {min_words})")
    if code_blocks < 1: err(f"{lid}: no code block")
    if "## Learning objectives" not in text: err(f"{lid}: missing '## Learning objectives'")
    if "## Summary" not in text: err(f"{lid}: missing '## Summary'")
    if text.count("```") % 2: err(f"{lid}: unbalanced code fences")
    if PLACEHOLDERS.search(text): err(f"{lid}: placeholder text found")

def check_module(path, course):
    lines = open(path, encoding="utf-8").read().split("\n")
    if not lines[0].startswith("@module "): err(f"{path}: must start with @module")
    i = 0
    lessons = 0
    while i < len(lines):
        if lines[i].startswith("@lesson "):
            parts = [p.strip() for p in lines[i][8:].split("|")]
            lid = parts[0]
            if lid in seen_ids: err(f"duplicate lesson id {lid}")
            seen_ids.add(lid)
            if len(parts) < 3 or not parts[2].isdigit(): err(f"{lid}: header needs 'id | title | minutes'")
            j = i + 1; in_code = False; body = []
            while j < len(lines):
                l = lines[j]
                if l.strip().startswith("```"): in_code = not in_code
                if not in_code and (l.strip() == "@quiz" or l.startswith("@lesson ")): break
                body.append(l); j += 1
            if j >= len(lines) or lines[j].strip() != "@quiz": err(f"{lid}: missing @quiz"); i = j; continue
            k = j + 1; in_code = False; quiz = []
            while k < len(lines):
                l = lines[k]
                if l.strip().startswith("```"): in_code = not in_code
                if not in_code and l.startswith("@lesson "): break
                quiz.append(l); k += 1
            check_body(body, lid, course == "projects")
            check_questions(quiz, lid)
            stats["lessons"] += 1; lessons += 1
            i = k
        else:
            i += 1
    return lessons

def main():
    summary = {}
    for course in ("dart", "flutter", "projects"):
        d = os.path.join(ROOT, course)
        files = sorted(f for f in os.listdir(d) if f.endswith(".bimo") and f != "course.bimo")
        summary[course] = (len(files), sum(check_module(os.path.join(d, f), course) for f in files))
    exam = os.path.join(ROOT, "final", "exam.bimo")
    if os.path.exists(exam):
        lines = open(exam, encoding="utf-8").read().split("\n")
        check_questions(lines[1:], "final-exam", 20, 40)
    else:
        err("final/exam.bimo missing")
    ch = os.path.join(ROOT, "challenges.bimo")
    nch = open(ch, encoding="utf-8").read().count("@challenge ") if os.path.exists(ch) else 0
    for c, (m, l) in summary.items():
        print(f"{c:9s} modules={m:3d} lessons={l:4d}")
    print(f"total lessons={stats['lessons']} questions={stats['questions']} words={stats['words']} code_blocks={stats['code_blocks']} challenges={nch}")
    if errors:
        print(f"\n{len(errors)} problem(s):")
        for e in errors: print(" -", e)
        sys.exit(1)
    print("OK")

if __name__ == "__main__":
    main()
