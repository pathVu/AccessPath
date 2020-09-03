package com.pathvu.accesspath2020.Util
//
//import com.android.volley.toolbox.HurlStack
//import com.squareup.okhttp.OkHttpClient
//import java.io.IOException
//import java.net.HttpURLConnection
//import java.net.URL
//
//class OkHttpStack @JvmOverloads constructor(client: OkHttpClient = OkHttpClient()) : HurlStack() {
//    private val mFactory: OkUrlFactory
//    init {
//        mFactory = OkUrlFactory(client)
//    }
//    @Throws(IOException::class)
//    override fun createConnection(url: URL): HttpURLConnection {
//        return mFactory.open(url)
//    }
//}