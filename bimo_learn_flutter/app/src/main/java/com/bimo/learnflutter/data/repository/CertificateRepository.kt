package com.bimo.learnflutter.data.repository

import com.bimo.learnflutter.core.domain.CertificateIdGenerator
import com.bimo.learnflutter.core.domain.CertificateRules
import com.bimo.learnflutter.data.db.dao.CertificateDao
import com.bimo.learnflutter.data.db.dao.ProfileDao
import com.bimo.learnflutter.data.db.entity.CertificateEntity
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import javax.inject.Inject
import javax.inject.Singleton

enum class VerificationResult { VALID, MALFORMED, NOT_FOUND }

@Singleton
class CertificateRepository @Inject constructor(
    private val dao: CertificateDao,
    private val profileDao: ProfileDao,
    private val learning: LearningRepository,
    private val time: TimeProvider,
) {
    val certificates: Flow<List<CertificateEntity>> = dao.observeAll()

    suspend fun get(id: String): CertificateEntity? = dao.get(id)

    /**
     * Issues the certificate once the learner is eligible. Calling it again returns the existing
     * certificate, so the id stays stable forever.
     */
    suspend fun issueIfEligible(): CertificateEntity? {
        val eligibility = learning.certificateEligibility.first()
        if (!eligibility.eligible) return null
        dao.observeAll().first().firstOrNull()?.let { return it }
        val name = profileDao.get()?.name ?: "Bimo Learner"
        val score = learning.bestFinalExamPercent() ?: return null
        var id: String
        do {
            id = CertificateIdGenerator.generate(time.today())
        } while (dao.get(id) != null)
        val entity = CertificateEntity(
            certificateId = id,
            learnerName = name,
            courseTitle = CertificateRules.COURSE_TITLE,
            issuedAt = time.nowMillis(),
            finalScore = score,
        )
        dao.insert(entity)
        return entity
    }

    suspend fun verify(rawId: String): VerificationResult {
        val id = rawId.trim().uppercase()
        if (!CertificateIdGenerator.isWellFormed(id)) return VerificationResult.MALFORMED
        return if (dao.get(id) != null) VerificationResult.VALID else VerificationResult.NOT_FOUND
    }
}
