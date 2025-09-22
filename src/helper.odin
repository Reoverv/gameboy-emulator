package main

import fmt "core:fmt"

decimalToHex16 :: proc(dec: u16) -> string {
    return fmt.tprintf("%04X", dec)
}

decimalToHex8 :: proc(dec: u8) -> string {
    return fmt.tprintf("%02X", dec)
}