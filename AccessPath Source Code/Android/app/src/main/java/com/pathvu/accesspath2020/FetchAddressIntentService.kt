package com.pathvu.accesspath2020

import android.app.IntentService
import android.content.Intent
import android.location.Address
import android.location.Geocoder
import android.os.Bundle
import android.os.ResultReceiver
import android.text.TextUtils
import android.util.Log
import com.google.android.gms.maps.model.LatLng
import java.io.IOException
import java.util.*
import kotlin.collections.ArrayList


class FetchAddressIntentService
/**
 * Creates an IntentService.  Invoked by your subclass's constructor.
 * @param name Used to name the worker thread, important only for debugging.
 */
@JvmOverloads constructor(name: String? = "AddressIntentService") : IntentService(name) {
    protected var mReceiver: ResultReceiver? = null
    private val TAG = "FetchAddress"
    private fun deliverResultToReceiver(resultCode: Int, message: String) {
        val bundle = Bundle()
        bundle.putString(RESULT_DATA_KEY, message)
        mReceiver?.send(resultCode, bundle)
    }

      /*fun onHandleIntent(intent: Intent) {

    }*/

    companion object Constant {
        const val SUCCESS_RESULT = 0
        const val FAILURE_RESULT = 1
        const val PACKAGE_NAME = "com.pathvu.accesspath2020"
        const val RECEIVER = "$PACKAGE_NAME.RECEIVER"
        const val RESULT_DATA_KEY = "${PACKAGE_NAME}.RESULT_DATA_KEY"
        const val LATLNG_DATA_EXTRA = "${PACKAGE_NAME}.LATLNG_DATA_EXTRA"
    }

    override fun onHandleIntent(intent: Intent?) {
        val geocoder = Geocoder(this, Locale.getDefault())
        var errorMessage = ""
        // Get the location passed to this service through an extra.
        val latLng: LatLng = intent!!.getParcelableExtra(
            LATLNG_DATA_EXTRA
        )
        mReceiver = intent.getParcelableExtra(RECEIVER)
        var addresses: List<Address>? = null
        // Get the address by latitude and longitude. Since there may be more than one address, depending on the accuracy of latitude and longitude, this example limits the maximum number of returns to 5
        try {
            addresses = geocoder.getFromLocation(
                latLng.latitude,
                latLng.longitude,
                5
            )
        } catch (ioException: IOException) { // Catch network or other I/O problems.
            errorMessage = "service_not_available"
            Log.e(TAG, errorMessage)
        } catch (illegalArgumentException: IllegalArgumentException) { // Catch invalid latitude or longitude values.
            errorMessage = "invalid_lat_long_used"
            Log.e(TAG, errorMessage)
        }
        // Handle case where no address was found.
        if (addresses == null || addresses.size == 0) {
            if (errorMessage.isEmpty()) {
                errorMessage = "no_address_found"
                Log.e(TAG, errorMessage)
            }
            deliverResultToReceiver(
                FAILURE_RESULT,
                errorMessage
            )
        } else {
            val address: Address = addresses[0]
            val addressFragments = ArrayList<String?>()
            addressFragments.add(address.getAddressLine(0))
            deliverResultToReceiver(
                SUCCESS_RESULT,
                TextUtils.join(
                    System.getProperty("line.separator").toString(),
                    addressFragments
                )
            )
        }
    }
}