package main

import fmt "core:fmt"

decimalToHex :: proc(dec: u16) -> string {

    return fmt.tprintf("%04X", dec)

}