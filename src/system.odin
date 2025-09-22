package main

import fmt "core:fmt"

initializeSystem :: proc(){
    
    initializeMemory()
    
    initializeCpu()
    
}

initializeMemory :: proc() {
    
    for i in 0..<len(memory) {
        memory[i] = 0
    }
    
    // Initialize I/O registers to their default values
    memory[0xFF05] = 0x00  // TIMA
    memory[0xFF06] = 0x00  // TMA  
    memory[0xFF07] = 0x00  // TAC
    memory[0xFF10] = 0x80  // NR10
    memory[0xFF11] = 0xBF  // NR11
    memory[0xFF12] = 0xF3  // NR12
    memory[0xFF14] = 0xBF  // NR14
    memory[0xFF16] = 0x3F  // NR21
    memory[0xFF17] = 0x00  // NR22
    memory[0xFF19] = 0xBF  // NR24
    memory[0xFF1A] = 0x7F  // NR30
    memory[0xFF1B] = 0xFF  // NR31
    memory[0xFF1C] = 0x9F  // NR32
    memory[0xFF1E] = 0xBF  // NR34
    memory[0xFF20] = 0xFF  // NR41
    memory[0xFF21] = 0x00  // NR42
    memory[0xFF22] = 0x00  // NR43
    memory[0xFF23] = 0xBF  // NR44
    memory[0xFF24] = 0x77  // NR50
    memory[0xFF25] = 0xF3  // NR51
    memory[0xFF26] = 0xF1  // NR52 (GB), 0xF0 (SGB)
    memory[0xFF40] = 0x91  // LCDC
    memory[0xFF42] = 0x00  // SCY
    memory[0xFF43] = 0x00  // SCX
    memory[0xFF45] = 0x00  // LYC
    memory[0xFF47] = 0xFC  // BGP
    memory[0xFF48] = 0xFF  // OBP0
    memory[0xFF49] = 0xFF  // OBP1
    memory[0xFF4A] = 0x00  // WY
    memory[0xFF4B] = 0x00  // WX
    memory[0xFFFF] = 0x00  // IE
}


initializeCpu :: proc(){
    cpu = cpu_context {
	register = register {
		AF = 0x01B0, // A=0x01, F=0xB0 (flags: Z=1, N=0, H=1, C=1)
		BC = 0x0013,
		DE = 0x00D8,
		HL = 0x014D,
		SP = 0xFFFE, // Stack Pointer
		PC = 0x0100,
	},
	halted = false,
    }
}