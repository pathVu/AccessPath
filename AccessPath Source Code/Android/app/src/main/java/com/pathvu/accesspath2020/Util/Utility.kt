package com.pathvu.accesspath2020.Util

import android.app.Activity
import android.app.Dialog
import android.content.DialogInterface
import androidx.appcompat.app.AlertDialog
import com.pathvu.accesspath2020.R
import java.math.BigDecimal


object Utility {
    /**
     * Converts value from meter to feet
     */
    fun convertMeterToFeet(length: Double): Double? {
        val distance = length / 0.3048
        val bd = BigDecimal(distance)
        return bd.setScale(2, BigDecimal.ROUND_HALF_UP).toDouble()
    }


    /**
     * Show alert dialog to request for permission.
     */
    fun showDialog(activity: Activity?, title: String?, message: String?, positiveButton: String?, negativeButton: String?, listener: OnAlertButtonClickListener) {
        val builder = AlertDialog.Builder(activity!!, R.style.AlertDialogTheme)
        builder.setMessage(message)
        builder.setCancelable(false)
        builder.setTitle(title)
        builder.setPositiveButton(
            positiveButton
        ) { dialogInterface, _ -> listener.onPositiveButtonClick(dialogInterface) }
        builder.setNegativeButton(
            negativeButton
        ) { dialogInterface, _ -> listener.onNegativeButtonClick(dialogInterface) }
        val dialog: Dialog = builder.create()
        dialog.show()
    }


    interface OnAlertButtonClickListener {
        fun onPositiveButtonClick(dialogInterface: DialogInterface?)
        fun onNegativeButtonClick(dialogInterface: DialogInterface?)
    }
}