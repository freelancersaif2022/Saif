package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.CertificateIdGenerator
import com.bimo.learnflutter.core.domain.CertificateRules
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDate
import kotlin.random.Random

class CertificatesTest {
    private val curriculum = TestFixtures.curriculum()
    private val all = curriculum.lessons.map { it.id }.toSet()

    @Test
    fun notEligibleWithoutLessons() {
        val e = CertificateRules.evaluate(curriculum, emptySet(), finalExamPassed = false)
        assertFalse(e.eligible)
        assertFalse(e.finalExamUnlocked)
        assertEquals(3, e.requirements.size)
    }

    @Test
    fun finalExamUnlocksAfterAllCourses() {
        val e = CertificateRules.evaluate(curriculum, all, finalExamPassed = false)
        assertTrue(e.finalExamUnlocked)
        assertFalse(e.eligible)
    }

    @Test
    fun eligibleAfterExam() {
        val e = CertificateRules.evaluate(curriculum, all, finalExamPassed = true)
        assertTrue(e.eligible)
        assertEquals(1f, e.overallFraction, 0.0001f)
    }

    @Test
    fun examPassWithoutLessonsDoesNotCount() {
        val e = CertificateRules.evaluate(curriculum, setOf("d1"), finalExamPassed = true)
        assertFalse(e.eligible)
    }

    @Test
    fun idsAreWellFormedAndUnique() {
        val date = LocalDate.of(2026, 10, 16)
        val random = Random(42)
        val ids = (1..500).map { CertificateIdGenerator.generate(date, random) }
        assertEquals(ids.size, ids.toSet().size)
        ids.forEach { assertTrue(it, CertificateIdGenerator.isWellFormed(it)) }
        assertTrue(ids.first().startsWith("BIMO-20261016-"))
    }

    @Test
    fun checkCharacterRejectsTypos() {
        val id = CertificateIdGenerator.generate(LocalDate.of(2026, 1, 2), Random(1))
        val chars = id.toCharArray()
        val pos = 15
        chars[pos] = if (chars[pos] == 'A') 'B' else 'A'
        val typo = String(chars)
        assertNotEquals(id, typo)
        assertFalse(CertificateIdGenerator.isWellFormed(typo))
        assertTrue(CertificateIdGenerator.isWellFormed(id.lowercase()))
        assertFalse(CertificateIdGenerator.isWellFormed("hello"))
    }

    @Test
    fun disclaimerIsHonest() {
        assertTrue(CertificateRules.DISCLAIMER.contains("not an accredited"))
        assertEquals("Saif A", CertificateRules.SIGNATORY)
    }
}
