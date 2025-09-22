package main

import "core:bufio"
import fmt "core:fmt"
import "core:os"

cpu_context :: struct {
	register:           register,
	fetchedData:        u16,
	memoryDestination:  u16,
	currentOpCode:      u16,
	currentInstruction: instruction,
	halted:             bool,
}

cpu: cpu_context = {}

register :: struct {
	AF: u16,
	BC: u16,
	DE: u16,
	HL: u16,
	SP: u16, // StackPointer
	PC: u16, // Program Counter/Pointer
}

getUpperRegister :: proc(register: u16) -> u8 {
	return u8(register >> 8)
}

getLowerRegister :: proc(register: u16) -> u8 {
	return u8(register)
}

formatFlags :: proc() -> string {
	return fmt.tprintfln(
		"Z: %d, N: %d, H: %d, C: %d",
		getZFlag(),
		getNFlag(),
		getHFlag(),
		getCFlag(),
	)
}

setUpperRegister :: proc(registerPtr: ^u16, value: u8) {
	lowerBits := registerPtr^ & 0x00FF
	upperBits := u16(value) << 8
	registerPtr^ = upperBits | lowerBits
}

setLowerRegister :: proc(registerPtr: ^u16, value: u8) {

	lowerBits := u16(value)
	upperBits := registerPtr^ & 0xFF00
	registerPtr^ = upperBits | lowerBits
}


setZFlag :: proc(value: u8) {
	cleared := getLowerRegister(cpu.register.AF) & 0x7F
	setLowerRegister(&cpu.register.AF, cleared | (value << 7))
}

setNFlag :: proc(value: u8) {
	cleared := getLowerRegister(cpu.register.AF) & 0xBF
	setLowerRegister(&cpu.register.AF, cleared | (value << 6))
}

setHFlag :: proc(value: u8) {
	cleared := getLowerRegister(cpu.register.AF) & 0xDF
	setLowerRegister(&cpu.register.AF, cleared | (value << 5))
}

setCFlag :: proc(value: u8) {
	cleared := getLowerRegister(cpu.register.AF) & 0xEF
	setLowerRegister(&cpu.register.AF, cleared | (value << 4))
}

getZFlag :: proc() -> u8 {
	return (getLowerRegister(cpu.register.AF) >> 7) & 0x01
}

getNFlag :: proc() -> u8 {
	return (getLowerRegister(cpu.register.AF) >> 6) & 0x01
}

getHFlag :: proc() -> u8 {
	return (getLowerRegister(cpu.register.AF) >> 5) & 0x01
}

getCFlag :: proc() -> u8 {
	return (getLowerRegister(cpu.register.AF) >> 4) & 0x01
}

fetchData :: proc() {
	if cpu.currentInstruction.lenght == 2 {
		high := memory[cpu.register.PC + 2]
		low := memory[cpu.register.PC + 1]


		cpu.fetchedData = (u16(high) << 8) | u16(low)
		return
	}

	if cpu.currentInstruction.lenght == 0 {
		cpu.fetchedData = 0
		return
	}

	value := memory[cpu.register.PC + cpu.currentInstruction.lenght]
	cpu.fetchedData = u16(value)
}

printRegToHex :: proc() -> string {
	return fmt.tprintfln(
		"AF: 0x%s | BC: 0x%s | DE: 0x%s | HL: 0x%s | SP: 0x%s | PC: 0x%s\nFlags: %s",
		decimalToHex16(cpu.register.AF),
		decimalToHex16(cpu.register.BC),
		decimalToHex16(cpu.register.DE),
		decimalToHex16(cpu.register.HL),
		decimalToHex16(cpu.register.SP),
		decimalToHex16(cpu.register.PC),
		formatFlags(),
	)
}

run :: proc() {
	debug := true

	for !cpu.halted {
		curInstruction := memory[cpu.register.PC]
		cpu.currentInstruction = instructions[curInstruction]
		cpu.currentOpCode = u16(curInstruction)

		// Use bufio to read a line instead


		fetchData()
		has_run := runInstruction()

		if has_run && debug {
			line_buf := make([]u8, 1024)
			defer delete(line_buf)
			os.read(os.stdin, line_buf)
		}

		if cpu.register.PC >= len(memory) - 1 {
			cpu.halted = true
		}
	}

}
