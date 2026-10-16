package com.bimo.learnflutter.core.content

enum class TokenKind { KEYWORD, TYPE, STRING, NUMBER, COMMENT, ANNOTATION, FUNCTION, PUNCTUATION, PLAIN }

data class CodeToken(val start: Int, val end: Int, val kind: TokenKind)

/**
 * A small, allocation-light lexer used for syntax highlighting of Dart (and, loosely, Kotlin,
 * YAML, JSON and shell) snippets. It does not aim to be a full parser: it recognises comments,
 * strings (including triple-quoted and raw strings), numbers, keywords, annotations, capitalised
 * type names and function calls, which is what readers rely on visually.
 */
object CodeTokenizer {
    private val DART_KEYWORDS = setOf(
        "abstract", "as", "assert", "async", "await", "base", "break", "case", "catch", "class", "const",
        "continue", "covariant", "default", "deferred", "do", "dynamic", "else", "enum", "export",
        "extends", "extension", "external", "factory", "false", "final", "finally", "for", "Function",
        "get", "hide", "if", "implements", "import", "in", "interface", "is", "late", "library", "mixin",
        "new", "null", "of", "on", "operator", "part", "required", "rethrow", "return", "sealed", "set",
        "show", "static", "super", "switch", "sync", "this", "throw", "true", "try", "typedef", "var",
        "void", "when", "while", "with", "yield", "int", "double", "num", "bool", "String", "Never", "Object",
    )
    private val KOTLIN_KEYWORDS = setOf(
        "fun", "val", "var", "class", "object", "interface", "data", "sealed", "when", "if", "else", "return",
        "import", "package", "private", "override", "suspend", "true", "false", "null", "for", "while", "in", "is",
    )
    private val YAML_KEYWORDS = setOf("true", "false", "null")

    fun tokenize(code: String, language: String): List<CodeToken> {
        val lang = language.lowercase()
        val keywords = when (lang) {
            "kotlin", "kt" -> KOTLIN_KEYWORDS
            "yaml", "yml", "json" -> YAML_KEYWORDS
            "bash", "shell", "sh", "text", "diagram", "plaintext" -> emptySet()
            else -> DART_KEYWORDS
        }
        val hashComments = lang in setOf("yaml", "yml", "bash", "shell", "sh")
        val tokens = ArrayList<CodeToken>()
        var i = 0
        val n = code.length
        if (lang == "text" || lang == "diagram" || lang == "plaintext") return tokens
        while (i < n) {
            val c = code[i]
            when {
                hashComments && c == '#' -> {
                    val end = code.indexOf('\n', i).let { if (it < 0) n else it }
                    tokens += CodeToken(i, end, TokenKind.COMMENT); i = end
                }
                !hashComments && c == '/' && i + 1 < n && code[i + 1] == '/' -> {
                    val end = code.indexOf('\n', i).let { if (it < 0) n else it }
                    tokens += CodeToken(i, end, TokenKind.COMMENT); i = end
                }
                !hashComments && c == '/' && i + 1 < n && code[i + 1] == '*' -> {
                    val close = code.indexOf("*/", i + 2)
                    val end = if (close < 0) n else close + 2
                    tokens += CodeToken(i, end, TokenKind.COMMENT); i = end
                }
                c == '"' || c == '\'' -> {
                    val raw = i > 0 && code[i - 1] == 'r' && (i < 2 || !code[i - 2].isLetterOrDigit())
                    val start = if (raw) i - 1 else i
                    val end = stringEnd(code, i, raw)
                    if (raw && tokens.isNotEmpty() && tokens.last().end > start) tokens.removeAt(tokens.lastIndex)
                    tokens += CodeToken(start, end, TokenKind.STRING); i = end
                }
                c.isDigit() -> {
                    var j = i
                    while (j < n && (code[j].isLetterOrDigit() || code[j] == '.' || code[j] == '_')) {
                        if (code[j] == '.' && (j + 1 >= n || !code[j + 1].isDigit())) break
                        j++
                    }
                    tokens += CodeToken(i, j, TokenKind.NUMBER); i = j
                }
                c == '@' && lang != "yaml" -> {
                    var j = i + 1
                    while (j < n && (code[j].isLetterOrDigit() || code[j] == '_' || code[j] == '.')) j++
                    tokens += CodeToken(i, j, TokenKind.ANNOTATION); i = j
                }
                c.isLetter() || c == '_' || c == '$' -> {
                    var j = i
                    while (j < n && (code[j].isLetterOrDigit() || code[j] == '_' || code[j] == '$')) j++
                    val word = code.substring(i, j)
                    var k = j
                    while (k < n && code[k] == ' ') k++
                    val kind = when {
                        word in keywords -> TokenKind.KEYWORD
                        lang == "yaml" || lang == "yml" -> if (k < n && code[k] == ':') TokenKind.FUNCTION else TokenKind.PLAIN
                        word[0].isUpperCase() -> TokenKind.TYPE
                        k < n && code[k] == '(' -> TokenKind.FUNCTION
                        else -> TokenKind.PLAIN
                    }
                    if (kind != TokenKind.PLAIN) tokens += CodeToken(i, j, kind)
                    i = j
                }
                c in "{}()[];,.=<>+-*/!?:&|%" -> {
                    tokens += CodeToken(i, i + 1, TokenKind.PUNCTUATION); i++
                }
                else -> i++
            }
        }
        return tokens
    }

    private fun stringEnd(code: String, start: Int, raw: Boolean): Int {
        val quote = code[start]
        val n = code.length
        val triple = start + 2 < n && code[start + 1] == quote && code[start + 2] == quote
        if (triple) {
            val close = code.indexOf("$quote$quote$quote", start + 3)
            return if (close < 0) n else close + 3
        }
        var i = start + 1
        while (i < n) {
            val c = code[i]
            if (c == '\\' && !raw) { i += 2; continue }
            if (c == quote) return i + 1
            if (c == '\n') return i
            i++
        }
        return n
    }
}
