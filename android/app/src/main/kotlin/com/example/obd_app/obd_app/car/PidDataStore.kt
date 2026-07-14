package com.example.obd_app.obd_app.car

/**
 * In-memory holder for the latest PID snapshot pushed from Dart via [MethodChannel].
 * Bridges the Flutter engine (which owns the OBD/BLE connection) and the Car App
 * Library screen, which runs independently of the phone UI.
 */
object PidDataStore {
    @Volatile
    var values: Map<String, String> = emptyMap()
        private set

    private val listeners = mutableListOf<() -> Unit>()

    fun update(newValues: Map<String, String>) {
        values = newValues
        listeners.forEach { it() }
    }

    fun addListener(listener: () -> Unit) {
        listeners.add(listener)
    }

    fun removeListener(listener: () -> Unit) {
        listeners.remove(listener)
    }
}
