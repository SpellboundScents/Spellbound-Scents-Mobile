package com.spellbound.crispy

object Crispy {
    init { System.loadLibrary("crispybridge") }
    @JvmStatic external fun run(args: Array<String>): Int
}