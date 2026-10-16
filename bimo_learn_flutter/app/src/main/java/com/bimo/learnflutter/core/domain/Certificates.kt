package com.bimo.learnflutter.core.domain

import com.bimo.learnflutter.core.content.Curriculum
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import kotlin.random.Random

data class CertificateRequirement(
    val label: String,
    val done: Int,
    val total: Int,
) {
    val met: Boolean get() = total > 0 && done >= total
    val fraction: Float get() = if (total == 0) 0f else (done.toFloat() / total).coerceAtMost(1f)
}

data class CertificateEligibility(
    val requirements: List<CertificateRequirement>,
    val finalExamUnlocked: Boolean,
    val finalExamPassed: Boolean,
) {
    val eligible: Boolean get() = requirements.all { it.met } && finalExamPassed
    val overallFraction: Float
        get() {
            val total = requirements.sumOf { it.total } + 1
            val done = requirements.sumOf { minOf(it.done, it.total) } + if (finalExamPassed) 1 else 0
            return done.toFloat() / total
        }
}

object CertificateRules {
    const val COURSE_TITLE = "Complete Flutter & Dart Development"
    const val SIGNATORY = "Saif A"
    const val DISCLAIMER =
        "This is an educational course-completion certificate issued by the Bimo learning app. " +
            "It is not an accredited professional licence and is not an official Google or Flutter certification."

    /** Course ids whose every lesson must be completed before the final assessment unlocks. */
    val REQUIRED_COURSES = listOf("dart", "flutter", "projects")

    fun evaluate(curriculum: Curriculum, completed: Set<String>, finalExamPassed: Boolean): CertificateEligibility {
        val requirements = REQUIRED_COURSES.mapNotNull { id ->
            curriculum.course(id)?.let { course ->
                CertificateRequirement(
                    label = course.title,
                    done = course.lessons.count { it.id in completed },
                    total = course.lessonCount,
                )
            }
        }
        val unlocked = requirements.isNotEmpty() && requirements.all { it.met }
        return CertificateEligibility(requirements, unlocked, finalExamPassed && unlocked)
    }
}

/**
 * Certificate ids look like `BIMO-20261016-7KQ2M9XA-C`: a prefix, the issue date, eight random
 * base-32 characters and a check character. The check character lets the app reject mistyped ids
 * before looking them up.
 */
object CertificateIdGenerator {
    private const val ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ" // Crockford base-32, no I L O U
    private val DATE = DateTimeFormatter.BASIC_ISO_DATE

    fun generate(issueDate: LocalDate, random: Random = Random.Default): String {
        val body = buildString { repeat(8) { append(ALPHABET[random.nextInt(ALPHABET.length)]) } }
        val core = "BIMO-${issueDate.format(DATE)}-$body"
        return "$core-${checkChar(core)}"
    }

    fun isWellFormed(id: String): Boolean {
        val normalized = id.trim().uppercase()
        val match = Regex("^BIMO-\\d{8}-[$ALPHABET]{8}-[$ALPHABET]$").matches(normalized)
        if (!match) return false
        val core = normalized.substringBeforeLast('-')
        return normalized.last() == checkChar(core)
    }

    /** Luhn mod N over the base-32 alphabet: detects every single-character substitution. */
    private fun checkChar(core: String): Char {
        val n = ALPHABET.length
        var factor = 2
        var sum = 0
        for (c in core.reversed()) {
            val value = ALPHABET.indexOf(c)
            if (value < 0) continue
            var addend = factor * value
            factor = if (factor == 2) 1 else 2
            addend = addend / n + addend % n
            sum += addend
        }
        return ALPHABET[(n - sum % n) % n]
    }
}
