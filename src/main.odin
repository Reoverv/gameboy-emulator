package main

import fmt "core:fmt"

WINDOW_HEIGHT :: 1152
WINDOW_WIDTH :: 1280

rom: []string

main :: proc() {

    debug : bool = true
    
    initializeSystem()

	loadCartridge("/Users/remco.overvliet/ownCloud/Programming/GBEmulator/tests/03.gb")


	run()

}
