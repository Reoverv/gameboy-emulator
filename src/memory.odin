package main

import fmt "core:fmt"


memory : [0x10000]u8 = {}

readMem :: proc(adress: u16) -> u8 {
    return memory[adress]
}

writeMem :: proc (adress : u16, value: u8) {
    memory[adress] = value
}


readAroundMemory :: proc(adress: u16) {
    
    fmt.println("Memory read at address: ", adress)
    
    if checkOutOfBound(adress - 5){ fmt.println(readMem(adress - 5))}
    if checkOutOfBound(adress -4) {fmt.println(readMem(adress - 4))}
    if checkOutOfBound(adress -3) {fmt.println(readMem(adress - 3))}
    if checkOutOfBound(adress -2) {fmt.println(readMem(adress - 2))}
    if checkOutOfBound(adress -1) {fmt.println(readMem(adress - 1))}
    fmt.println(readMem(adress))
    if checkOutOfBound(adress + 1) {fmt.println(readMem(adress + 1))}
    if checkOutOfBound(adress + 2) {fmt.println(readMem(adress + 2))}
    if checkOutOfBound(adress + 3) {fmt.println(readMem(adress + 3))}
    if checkOutOfBound(adress + 4) {fmt.println(readMem(adress + 4))}
    if checkOutOfBound(adress + 5) {fmt.println(readMem(adress + 5))}
    
}

checkOutOfBound :: proc(adress: u16) -> bool {
    if adress < 0x00 || adress > 0xFFFF{
        return false
    }
    
    return true
}



