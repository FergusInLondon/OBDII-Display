package com.example.obd_app.obd_app.car

import android.content.Intent
import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

class PidCarAppService : CarAppService() {

    override fun createHostValidator(): HostValidator {
        // Prototype only: accepts any host, including the Desktop Head Unit.
        // Restrict to production Android Auto/Automotive hosts before shipping,
        // e.g. HostValidator.Builder(applicationContext)
        //     .addAllowedHosts(R.array.hosts_allowlist_sample)
        //     .build()
        return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
    }

    override fun onCreateSession(): Session {
        return object : Session() {
            override fun onCreateScreen(intent: Intent) = PidDashboardScreen(carContext)
        }
    }
}
