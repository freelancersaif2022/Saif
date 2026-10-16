package com.bimo.learnflutter

import com.bimo.learnflutter.core.content.CodeTokenizer
import com.bimo.learnflutter.core.content.TokenKind
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CodeTokenizerTest {
    private fun kinds(code: String, lang: String = "dart") =
        CodeTokenizer.tokenize(code, lang).map { code.substring(it.start, it.end) to it.kind }

    @Test
    fun dartTokens() {
        val t = kinds("final name = 'Bimo'; // hi\nprint(name);")
        assertTrue(("final" to TokenKind.KEYWORD) in t)
        assertTrue(("'Bimo'" to TokenKind.STRING) in t)
        assertTrue(("// hi" to TokenKind.COMMENT) in t)
        assertTrue(("print" to TokenKind.FUNCTION) in t)
    }

    @Test
    fun annotationsTypesNumbers() {
        val t = kinds("@override\nWidget build() => Text('a', maxLines: 2.5);")
        assertTrue(("@override" to TokenKind.ANNOTATION) in t)
        assertTrue(("Widget" to TokenKind.TYPE) in t)
        assertTrue(("2.5" to TokenKind.NUMBER) in t)
    }

    @Test
    fun tripleAndRawStrings() {
        val code = "var a = '''x\ny'''; var b = r'\\d+';"
        val t = kinds(code)
        assertTrue(("'''x\ny'''" to TokenKind.STRING) in t)
        assertTrue(("r'\\d+'" to TokenKind.STRING) in t)
    }

    @Test
    fun yamlHashComments() {
        val t = kinds("name: app # comment", "yaml")
        assertEquals("name" to TokenKind.FUNCTION, t.first())
        assertTrue(("# comment" to TokenKind.COMMENT) in t)
    }

    @Test
    fun plainTextHasNoTokens() {
        assertTrue(CodeTokenizer.tokenize("anything", "diagram").isEmpty())
    }
}
