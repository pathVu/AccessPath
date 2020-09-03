package com.pathvu.accesspath2020.listener

/**
 * This interface is used for asynchronous navigation functions returning values.
 * For example, counting number of hazards may take some time so this interface
 * is used for returning the count when completed.
 */
interface NavigationListener<T> {
    fun on(arg: T)
}