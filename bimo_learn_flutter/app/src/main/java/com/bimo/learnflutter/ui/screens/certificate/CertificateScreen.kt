package com.bimo.learnflutter.ui.screens.certificate

import android.graphics.Bitmap
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.FactCheck
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.PictureAsPdf
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.certificate.CertificateData
import com.bimo.learnflutter.certificate.CertificateExporter
import com.bimo.learnflutter.certificate.CertificateRenderer
import com.bimo.learnflutter.certificate.ExportResult
import com.bimo.learnflutter.core.domain.CertificateEligibility
import com.bimo.learnflutter.core.domain.CertificateRules
import com.bimo.learnflutter.data.db.entity.CertificateEntity
import com.bimo.learnflutter.data.repository.CertificateRepository
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.VerificationResult
import com.bimo.learnflutter.ui.components.ConfettiOverlay
import com.bimo.learnflutter.ui.components.GradientProgressBar
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.practice.TopBar
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject

data class CertificateUiState(
    val loading: Boolean = true,
    val eligibility: CertificateEligibility? = null,
    val certificate: CertificateEntity? = null,
    val preview: Bitmap? = null,
    val message: String? = null,
    val verification: String? = null,
)

@HiltViewModel
class CertificateViewModel @Inject constructor(
    learning: LearningRepository,
    private val certificates: CertificateRepository,
    private val exporter: CertificateExporter,
) : ViewModel() {
    private val local = MutableStateFlow(CertificateUiState())
    private var renderedFor: CertificateEntity? = null

    val state: StateFlow<CertificateUiState> = combine(local, learning.certificateEligibility, certificates.certificates) { l, e, certs ->
        val cert = certs.firstOrNull()
        if (cert != null && cert != renderedFor) render(cert)
        l.copy(loading = false, eligibility = e, certificate = cert)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), CertificateUiState())

    init {
        // Issues the certificate if the learner became eligible earlier but it was never created.
        viewModelScope.launch { certificates.issueIfEligible() }
    }

    private fun render(cert: CertificateEntity) {
        renderedFor = cert
        viewModelScope.launch {
            val bmp = withContext(Dispatchers.Default) { CertificateRenderer.renderBitmap(cert.toData(), scale = 0.6f) }
            local.update { it.copy(preview = bmp) }
        }
    }

    fun savePdf() = export { exporter.savePdf(it) }
    fun saveImage() = export { exporter.saveImage(it) }

    private fun export(block: suspend (CertificateData) -> ExportResult) {
        val cert = state.value.certificate ?: return
        viewModelScope.launch {
            val msg = when (val r = block(cert.toData())) {
                is ExportResult.Saved -> "Saved to ${r.location}"
                is ExportResult.Failed -> "Export failed: ${r.message}"
            }
            local.update { it.copy(message = msg) }
        }
    }

    suspend fun shareIntent(asPdf: Boolean) = state.value.certificate?.let { exporter.shareIntent(it.toData(), asPdf) }

    fun verify(id: String) {
        viewModelScope.launch {
            val text = when (certificates.verify(id)) {
                VerificationResult.VALID -> "✔ Valid: this certificate was issued by Bimo on this device."
                VerificationResult.MALFORMED -> "✘ This is not a valid Bimo certificate ID (check for typos)."
                VerificationResult.NOT_FOUND -> "The ID is well-formed but was not issued on this device."
            }
            local.update { it.copy(verification = text) }
        }
    }

    private fun CertificateEntity.toData() = CertificateData(certificateId, learnerName, courseTitle, issuedAt, finalScore)
}

@Composable
fun CertificateScreen(navigator: BimoNavigator, viewModel: CertificateViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var verifyInput by remember { mutableStateOf("") }

    if (state.loading) { ListSkeleton(); return }
    val cert = state.certificate
    val eligibility = state.eligibility

    Box(Modifier.fillMaxSize()) {
        Column(Modifier.fillMaxSize().statusBarsPadding()) {
            TopBar("Certificate", navigator)
            Column(
                Modifier.verticalScroll(rememberScrollState()).navigationBarsPadding().padding(horizontal = 20.dp, vertical = 8.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                if (cert != null) {
                    Text("Congratulations, ${cert.learnerName}!", style = MaterialTheme.typography.headlineSmall)
                    Surface(shape = RoundedCornerShape(12.dp), shadowElevation = 6.dp) {
                        val preview = state.preview
                        if (preview != null) {
                            Image(
                                preview.asImageBitmap(),
                                contentDescription = "Certificate of completion for ${cert.learnerName}, ${cert.courseTitle}, final score ${cert.finalScore} percent, ID ${cert.certificateId}",
                                modifier = Modifier.fillMaxWidth().aspectRatio(CertificateRenderer.WIDTH / CertificateRenderer.HEIGHT.toFloat()),
                            )
                        } else {
                            Box(Modifier.fillMaxWidth().aspectRatio(1.414f).background(MaterialTheme.colorScheme.surfaceVariant))
                        }
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        Button(onClick = { scope.launch { viewModel.shareIntent(false)?.let(context::startActivity) } }, modifier = Modifier.weight(1f)) {
                            Icon(Icons.Filled.Share, null); Spacer(Modifier.width(6.dp)); Text("Share")
                        }
                        OutlinedButton(onClick = { scope.launch { viewModel.shareIntent(true)?.let(context::startActivity) } }, modifier = Modifier.weight(1f)) {
                            Text("Share PDF")
                        }
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedButton(onClick = viewModel::savePdf, modifier = Modifier.weight(1f)) {
                            Icon(Icons.Filled.PictureAsPdf, null); Spacer(Modifier.width(6.dp)); Text("Save PDF")
                        }
                        OutlinedButton(onClick = viewModel::saveImage, modifier = Modifier.weight(1f)) {
                            Icon(Icons.Filled.Image, null); Spacer(Modifier.width(6.dp)); Text("Save image")
                        }
                    }
                    state.message?.let { Text(it, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.primary) }
                    Surface(shape = RoundedCornerShape(16.dp), color = MaterialTheme.colorScheme.surfaceContainerLow) {
                        Column(Modifier.padding(14.dp)) {
                            Text("Certificate ID: ${cert.certificateId}", style = MaterialTheme.typography.labelLarge)
                            Spacer(Modifier.height(4.dp))
                            Text(CertificateRules.DISCLAIMER, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                } else {
                    Box(
                        Modifier.fillMaxWidth().clip(RoundedCornerShape(24.dp)).background(BimoGradients.Premium).padding(20.dp),
                    ) {
                        Column {
                            Text("BIMO — CERTIFICATE OF COMPLETION", style = MaterialTheme.typography.labelLarge, color = BimoColors.Gold)
                            Text(CertificateRules.COURSE_TITLE, style = MaterialTheme.typography.headlineSmall, color = Color.White)
                            Spacer(Modifier.height(10.dp))
                            GradientProgressBar(eligibility?.overallFraction ?: 0f, brush = BimoGradients.Gold)
                            Spacer(Modifier.height(6.dp))
                            Text(
                                "${((eligibility?.overallFraction ?: 0f) * 100).toInt()}% of requirements complete",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color.White.copy(alpha = 0.85f),
                            )
                        }
                    }
                    Text("Requirements", style = MaterialTheme.typography.titleLarge)
                    eligibility?.requirements?.forEach { r ->
                        Requirement("Complete ${r.label}", "${r.done}/${r.total} lessons", r.met, r.fraction)
                    }
                    Requirement(
                        "Pass the final assessment (70%)",
                        if (eligibility?.finalExamUnlocked == true) "Unlocked" else "Locked until all courses are complete",
                        eligibility?.finalExamPassed == true,
                        if (eligibility?.finalExamPassed == true) 1f else 0f,
                    )
                    Button(
                        onClick = { navigator.to(Routes.finalExam()) },
                        enabled = eligibility?.finalExamUnlocked == true,
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                    ) {
                        Icon(if (eligibility?.finalExamUnlocked == true) Icons.Filled.FactCheck else Icons.Filled.Lock, null)
                        Spacer(Modifier.width(8.dp))
                        Text("Take the final assessment")
                    }
                    OutlinedButton(onClick = { navigator.tab(Routes.COURSES) }, modifier = Modifier.fillMaxWidth()) {
                        Text("Continue learning")
                        Spacer(Modifier.width(6.dp))
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, null)
                    }
                    Text(CertificateRules.DISCLAIMER, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }

                Text("Verify a certificate", style = MaterialTheme.typography.titleMedium)
                OutlinedTextField(
                    value = verifyInput,
                    onValueChange = { verifyInput = it.uppercase().take(26) },
                    label = { Text("Certificate ID") },
                    placeholder = { Text("BIMO-20261016-XXXXXXXX-X") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Characters),
                    modifier = Modifier.fillMaxWidth(),
                )
                OutlinedButton(onClick = { viewModel.verify(verifyInput) }, enabled = verifyInput.isNotBlank()) {
                    Icon(Icons.Filled.Verified, null); Spacer(Modifier.width(6.dp)); Text("Verify")
                }
                state.verification?.let { Text(it, style = MaterialTheme.typography.bodyMedium) }
                Spacer(Modifier.height(24.dp))
            }
        }
        ConfettiOverlay(cert?.certificateId)
    }
}

@Composable
private fun Requirement(title: String, subtitle: String, met: Boolean, fraction: Float) {
    Surface(shape = RoundedCornerShape(16.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
        Row(Modifier.fillMaxWidth().padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(32.dp).clip(CircleShape).background(if (met) BimoColors.Success else MaterialTheme.colorScheme.surfaceVariant),
                contentAlignment = Alignment.Center,
            ) { if (met) Icon(Icons.Filled.Check, "Done", tint = Color.White, modifier = Modifier.size(18.dp)) }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.titleSmall)
                Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(6.dp))
                GradientProgressBar(fraction, height = 6.dp)
            }
        }
    }
}
