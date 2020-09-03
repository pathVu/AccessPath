package com.pathvu.accesspath2020

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import com.pathvu.accesspath2020.model.PlaceDetails

class NearbyDetailDialogFragment : DialogFragment(), View.OnClickListener {
//
//    companion object {
//        fun newInstance(name: String, distance: Float, vicinity: String): NearbyDetailDialogFragment {
//            val dialog = NearbyDetailDialogFragment()
//            val args = Bundle().apply {
//                name?.let { putString("name", it) }
//                distance?.let { putFloat("distance", it) }
//                vicinity?.let { putString("vicinity", it) }
//            }
//            dialog.arguments = args
//            return dialog
//        }
//    }
    interface OnNearbyItemClickedListener {
        fun onNearbyClick(placeDetail: PlaceDetails)
    }
    private var nearbyDetailListener: OnNearbyItemClickedListener? = null



    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        return inflater.inflate(R.layout.fragment_nearby_detail, container, false)
    }


//    var onResult: ((name: String, distance: Float, vicinity: String) -> Unit)? = null
//
//    override fun onActivityCreated(savedInstanceState: Bundle?) {
//        super.onActivityCreated(savedInstanceState)
//        val name = arguments?.getString("name")
//        val distance = arguments?.getFloat("distance")
//        val vicinity = arguments?.getString("vicinity")
//        if (vicinity != null && name != null && distance != null) {
//            onResult?.invoke(name, distance, vicinity)
//        }
//    }


    override fun onClick(v: View?) {
        when (v!!.id) {
            R.id.setPathButton -> onSetPathClicked(v)
            R.id.cancelButton -> onCancelClicked(v)
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is OnNearbyItemClickedListener) {
            nearbyDetailListener = context
        }
    }


    private fun onSetPathClicked(v: View) {

    }


    private fun onCancelClicked(v: View) {
        dismiss()
    }
}