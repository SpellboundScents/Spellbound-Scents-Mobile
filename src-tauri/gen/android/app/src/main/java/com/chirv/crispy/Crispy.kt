package com.chirv.crispy

object Crispy {
    init {
        // Loads libcrispybridge.so from /lib/arm64-v8a
        System.loadLibrary("crispybridge")
    }

    @JvmStatic external fun run(args: Array<String>): Int
}