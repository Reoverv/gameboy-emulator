package main

memory : [0x10000]u8 = {}

readMem :: proc(adress: u16) -> u8 {
    return memory[adress]
}

writeMem :: proc (adress : u16, value: u8) {
    memory[adress] = value
}


