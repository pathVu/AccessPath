package com.pathvu.accesspath2020.listener

/**
 * This interface is used for returning values from asynchronous requests when
 * they finish. Instead of blocking the program until the asynchronous request
 * is finished, we can use this interface to return the value when it is done.
 */
interface CustomListener<T> {
    fun getResult(obj: T)
}