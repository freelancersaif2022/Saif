package com.bimo.learnflutter.di

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.room.Room
import com.bimo.learnflutter.BuildConfig
import com.bimo.learnflutter.billing.MockSubscriptionGateway
import com.bimo.learnflutter.billing.PlayBillingSubscriptionGateway
import com.bimo.learnflutter.billing.SubscriptionGateway
import com.bimo.learnflutter.data.db.BimoDatabase
import com.bimo.learnflutter.data.db.dao.CertificateDao
import com.bimo.learnflutter.data.db.dao.ChallengeDao
import com.bimo.learnflutter.data.db.dao.EntitlementDao
import com.bimo.learnflutter.data.db.dao.ProfileDao
import com.bimo.learnflutter.data.prefs.bimoDataStore
import dagger.Lazy
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): BimoDatabase =
        Room.databaseBuilder(context, BimoDatabase::class.java, BimoDatabase.NAME)
            .addMigrations(*BimoDatabase.MIGRATIONS)
            .build()

    @Provides fun provideProfileDao(db: BimoDatabase): ProfileDao = db.profileDao()
    @Provides fun provideCertificateDao(db: BimoDatabase): CertificateDao = db.certificateDao()
    @Provides fun provideEntitlementDao(db: BimoDatabase): EntitlementDao = db.entitlementDao()
    @Provides fun provideChallengeDao(db: BimoDatabase): ChallengeDao = db.challengeDao()

    @Provides
    @Singleton
    fun provideDataStore(@ApplicationContext context: Context): DataStore<Preferences> = context.bimoDataStore

    /** Mock billing by default; flip USE_MOCK_BILLING to use Google Play Billing. */
    @Provides
    @Singleton
    fun provideSubscriptionGateway(
        mock: Lazy<MockSubscriptionGateway>,
        play: Lazy<PlayBillingSubscriptionGateway>,
    ): SubscriptionGateway = if (BuildConfig.USE_MOCK_BILLING) mock.get() else play.get()
}
