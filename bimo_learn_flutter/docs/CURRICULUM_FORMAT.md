# Bimo curriculum format (`.bimo`)

Curriculum content is plain UTF-8 text so educators can edit it without touching Kotlin.
Files are parsed at runtime by `CurriculumParser` and validated by unit tests
(`CurriculumAssetsTest`) and by `tools/validate_curriculum.py`.

## Layout
```
curriculum/
  <course>/course.bimo        course manifest (key: value lines)
  <course>/NN_slug.bimo       one module per file, sorted by file name
  final/exam.bimo             final assessment (@exam)
  challenges.bimo             optional coding challenges (@challenge)
```

## Course manifest keys
`id, title, subtitle, level, accent, icon, order, description`, optional
`requires: <module-id>` (course prerequisite) and `projects: true`.

## Module file
```
@module flutter-m03 | Layout and UI
@summary One-line description shown in the course screen.

@lesson flutter-m03-l01 | Container | 12
...lesson body (Markdown subset)...
@quiz
...questions...
```
Lesson ids must be globally unique and must never change once released (progress is stored by id).

## Lesson body (Markdown subset)
- `## Heading`, `### Subheading`
- paragraphs, `- bullets`, `1. numbered`
- fenced code: ```` ```dart ```` (also `yaml`, `bash`, `kotlin`, `json`, `diagram`)
- callouts: `> NOTE: …`, `> TIP: …`, `> WARNING: …`, `> MISTAKE: …`, `> IMPORTANT: …`
- collapsible blocks: `:::check Question?` … `:::` and `:::solution Title` … `:::`
- inline: `` `code` ``, `**bold**`, `*italic*`
- The first list after `## Learning objectives` is shown as the lesson's objectives.

## Questions
```
? mcq: Prompt            (also: scenario, output)
```dart                  optional code shown with the question
...
```
- wrong option
+ correct option         exactly one
> Explanation shown after answering.

? tf: Statement
= true                   or false
> Explanation.

? fill: Use the ___ keyword.
= const | final          accepted answers (case-insensitive)
> Explanation.

? order: Put the lines in order.
~ first line             correct order, leading spaces preserved
~ second line
> Explanation.
```
