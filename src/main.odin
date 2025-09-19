package main

import fmt "core:fmt"

WINDOW_HEIGHT :: 1152
WINDOW_WIDTH :: 1280

rom: []string

main :: proc() {


	loadCartridge("/Users/remco.overvliet/ownCloud/Programming/GBEmulator/tests/09-op r,r.gb")


	run()

}
