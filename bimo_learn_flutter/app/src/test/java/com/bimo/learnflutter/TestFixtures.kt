package com.bimo.learnflutter

import com.bimo.learnflutter.core.content.ContentSource
import com.bimo.learnflutter.core.content.Curriculum
import com.bimo.learnflutter.core.content.CurriculumParser
import java.io.File

object TestFixtures {
    private fun lesson(id: String, title: String) = """
@lesson $id | $title | 5
## Learning objectives
- Understand $title

Some text about $title.

```dart
void main() => print('$title');
```
@quiz
? mcq: Which is right?
- Wrong
+ Right
> Because.
? tf: Dart is statically typed.
= true
> Dart has a sound static type system.
? fill: Declare a constant with ___.
= const | final
> Both keep the value fixed.
? order: Put the lines in order.
~ void main() {
~   print('hi');
~ }
> A function body is enclosed in braces.
? output: What is printed?
```dart
print(1 + 1);
```
+ 2
- 11
> Integer addition.
""".trimIndent()

    private fun module(id: String, title: String, vararg lessons: Pair<String, String>) =
        "@module $id | $title\n@summary $title summary\n\n" + lessons.joinToString("\n") { lesson(it.first, it.second) }

    /** Two courses: "dart" (2 modules) and "projects" which requires dart-m1. */
    fun curriculum(): Curriculum {
        val dart = CurriculumParser.buildCourse(
            CurriculumParser.CourseManifest("dart", "Dart", "s", "d", "Beginner", "#03B6D4", "dart", 1, null, false),
            listOf(
                "01_a.bimo" to module("dart-m1", "Basics", "d1" to "Hello", "d2" to "Variables"),
                "02_b.bimo" to module("dart-m2", "More", "d3" to "Functions"),
            ),
        )
        val flutter = CurriculumParser.buildCourse(
            CurriculumParser.CourseManifest("flutter", "Flutter", "s", "d", "Beginner", "#6750F5", "flutter", 2, null, false),
            listOf("01_a.bimo" to module("flutter-m1", "Widgets", "f1" to "Widgets")),
        )
        val projects = CurriculumParser.buildCourse(
            CurriculumParser.CourseManifest("projects", "Projects", "s", "d", "All", "#B9F34C", "build", 3, "dart-m1", true),
            listOf("01_a.bimo" to module("projects-m1", "Apps", "p1" to "Counter", "p2" to "Todo")),
        )
        return Curriculum(listOf(dart, flutter, projects), null)
    }

    /** Reads the real shipped assets (Gradle runs unit tests with the module directory as cwd). */
    class FileContentSource(private val root: File) : ContentSource {
        override fun list(dir: String): List<String> = File(root, dir).list()?.sorted() ?: emptyList()
        override fun read(path: String): String = File(root, path).readText()
    }

    fun assetsRoot(): File {
        val candidates = listOf(File("src/main/assets"), File("app/src/main/assets"))
        return candidates.first { File(it, "curriculum").isDirectory }
    }
}
