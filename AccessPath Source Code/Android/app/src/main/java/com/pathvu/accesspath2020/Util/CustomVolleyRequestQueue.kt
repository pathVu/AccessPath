package com.pathvu.accesspath2020.Util
//
//import android.content.Context
//import com.android.volley.Cache
//import com.android.volley.Network
//import com.android.volley.RequestQueue
//
//import com.android.volley.toolbox.BasicNetwork
//
//import com.android.volley.toolbox.DiskBasedCache
//
//
//class CustomVolleyRequestQueue private constructor(context: Context) {
//    private var mRequestQueue: RequestQueue?
//
//    // Don't forget to start the volley request queue
//    val requestQueue: RequestQueue
//        get() {
//            if (mRequestQueue == null) {
//                val cache: Cache = DiskBasedCache(
//                    mCtx.getCacheDir(),
//                    10 * 1024 * 1024
//                )
//                val network: Network = BasicNetwork(OkHttpStack)
//                mRequestQueue = RequestQueue(cache, network)
//                // Don't forget to start the volley request queue
//                mRequestQueue!!.start()
//            }
//            return mRequestQueue!!
//        }
//
//    companion object {
//        private var mInstance: CustomVolleyRequestQueue? = null
//        private lateinit var mCtx: Context
//
//        @Synchronized
//        fun getInstance(context: Context): CustomVolleyRequestQueue? {
//            if (mInstance == null) {
//                mInstance = CustomVolleyRequestQueue(context)
//            }
//            return mInstance
//        }
//    }
//
//    init {
//        mCtx = context
//        mRequestQueue = requestQueue
//    }
//}