package com.example.obd_app.obd_app.car

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.ItemList
import androidx.car.app.model.ListTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

/**
 * Read-only PID list: renders whatever [PidDataStore] currently holds and
 * redraws whenever Dart pushes a new snapshot over the platform channel.
 */
class PidDashboardScreen(carContext: CarContext) : Screen(carContext), DefaultLifecycleObserver {

    private val onSnapshotUpdated: () -> Unit = { invalidate() }

    init {
        lifecycle.addObserver(this)
    }

    override fun onStart(owner: LifecycleOwner) {
        PidDataStore.addListener(onSnapshotUpdated)
    }

    override fun onStop(owner: LifecycleOwner) {
        PidDataStore.removeListener(onSnapshotUpdated)
    }

    override fun onGetTemplate(): Template {
        val values = PidDataStore.values
        val itemListBuilder = ItemList.Builder()

        if (values.isEmpty()) {
            itemListBuilder.addItem(
                Row.Builder()
                    .setTitle("Waiting for data")
                    .addText("Connect the adapter in the OBD-II phone app")
                    .build()
            )
        } else {
            // ListTemplate rows are host-limited (commonly 6 without pagination);
            // cap defensively rather than risk a host rejecting the template.
            values.entries.take(6).forEach { (label, value) ->
                itemListBuilder.addItem(
                    Row.Builder()
                        .setTitle(label)
                        .addText(value)
                        .build()
                )
            }
        }

        return ListTemplate.Builder()
            .setTitle("OBD-II PIDs")
            .setHeaderAction(Action.APP_ICON)
            .setSingleList(itemListBuilder.build())
            .build()
    }
}
