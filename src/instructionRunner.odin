package main

import fmt "core:fmt"
import os "core:os"

runInstruction :: proc() {

	currentInstruction: instruction = cpu.currentInstruction
	fetchedData := cpu.fetchedData

	if cpu.currentOpCode != 0 {

		fmt.printfln(
			"Current opcode: 0x%02X\n%v\nFetchedData: 0x%04X",
			cpu.currentOpCode,
			cpu.currentInstruction,
			cpu.fetchedData,
		)
	}

	#partial switch currentInstruction.type {

	case .LD:
		#partial switch currentInstruction.addrMode {
		case .R_N8, .R_N16:
			load_register_num(
				currentInstruction.reg1,
				fetchedData,
				currentInstruction.register1Size,
			)
		case .MR_R, .MR_N8, .HLI_R, .HLD_R:
			load_memory_register_or_num(
				currentInstruction.reg1,
				currentInstruction.reg2,
				fetchedData,
				currentInstruction.register2Size,
			)
		case .M_R:
			load_at_memory_register(
				currentInstruction.reg2,
				fetchedData,
				currentInstruction.register2Size,
			)
		case .R_MR, .R_HLI, .R_HLD:
			load_register_memory(
				currentInstruction.reg1,
				currentInstruction.reg2,
				currentInstruction.register1Size,
			)
		case .R_R:
			load_register_register(
				currentInstruction.reg1,
				currentInstruction.reg2,
				currentInstruction.register1Size,
				currentInstruction.register2Size,
				cpu.fetchedData,
			)
		}
	case .LDH:
		#partial switch currentInstruction.addrMode {
		case .MR_R:
			loadH_memory_register_or_num(currentInstruction.reg2, fetchedData)
		case .R_MR:
		}
	case .INC:
		#partial switch currentInstruction.addrMode {
		case .R:
			inc_register(currentInstruction.reg1, currentInstruction.register1Size)
		case .MR:
			inc_memory(currentInstruction.reg1, currentInstruction.register1Size)
		}
	case .DEC:
		#partial switch currentInstruction.addrMode {
		case .R:
			dec_register(currentInstruction.reg1, currentInstruction.register1Size)
		case .MR:
			dec_memory(currentInstruction.reg1, currentInstruction.register1Size)
		}
	case .ADD:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			add_register_register(
				currentInstruction.reg1,
				currentInstruction.reg2,
				currentInstruction.register1Size,
				currentInstruction.register2Size,
			)
		case .R_E8:
			add_sp_e8(cpu.fetchedData)
		case .R_N8:
			add_a_n8(fetchedData)
		case .R_MR:
			add_register_memory(fetchedData)
		}
	case .SUB:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			sub_register_register(
				currentInstruction.reg1,
				currentInstruction.reg2,
				currentInstruction.register1Size,
				currentInstruction.register2Size,
			)
		case .R_MR:
			sub_register_memory(
				fetchedData
			)

		}
	case .ADC:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			adc_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .R_N8:
			adc_register_data(currentInstruction.register2Size, fetchedData)
		case .R_MR:
			adc_register_memory(currentInstruction.register2Size)
		}
	case .AND:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			and_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .R_MR:
			and_register_memory()
		}
	case .XOR:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			xor_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .MR_R:
			xor_register_memory()
		}
	case .OR:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			or_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .MR_R:
			or_register_memory()
		case .R_N8:
			or_register_num(fetchedData)
		}
	case .CP:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			cp_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .MR_R:
			cp_register_memory()
		case .R_N8:
			cp_register_num(cpu.fetchedData)
		}
	case .RET:
		fmt.println(cpu.currentInstruction.lenght)
		ret_cc(currentInstruction.cc)
		return
	case .RETI:
		reti_cc(currentInstruction.cc)
		return
	case .POP:
		pop_register(currentInstruction.reg1)
	case .CALL:
		call_cc(cpu.fetchedData, currentInstruction.cc)
	case .PUSH:
		push_register(currentInstruction.reg1)
	case .RST:
		rst(cpu.fetchedData)
	case .SBC:
		#partial switch currentInstruction.addrMode {
		case .R_R:
			sbc_register_register(currentInstruction.reg2, currentInstruction.register2Size)
		case .R_N8:
			sbc_register_data(currentInstruction.register2Size, fetchedData)
		case .R_MR:
			sbc_register_memory(currentInstruction.register2Size)
		}
	case .JR:
		{
			#partial switch currentInstruction.addrMode {
			case .R_E8, .C_E8, .E8:
				{
					jr_e8(cpu.fetchedData, currentInstruction.cc)
					fmt.printfln(printRegToHex())
					return
				}
			case .C_N16:
				{
					jp_n16(cpu.fetchedData, currentInstruction.cc)
					fmt.printfln(printRegToHex())
					return
				}

			}
		}
	case .HALT:
		os.exit(99) // TODO: HALT Not yet implemented
	case .DI: // TODO: DI Not yet implemented
	case .EI: // TODO: EI Not yet implemented,
	case .PREFIX:
		{
			// TODO: PREFIX Not yet implemented
			fmt.println("Prefix not yet implemented")
			os.exit(-69)
		}
	case .JP:
		{
			jp_n16(cpu.fetchedData, currentInstruction.cc)
			fmt.printfln(printRegToHex())
			return
		}
	case .SCF:
		{
			setCFlag(1)
			setNFlag(0)
			setZFlag(0)
		}
	case .CCF:
		{
			setCFlag(getCFlag() == 1 ? 0 : 1)
			setNFlag(0)
			setZFlag(0)
		}
	case .CPL:
		{
			setUpperRegister(&cpu.register.AF, ~getUpperRegister(cpu.register.AF))
			setHFlag(1)
			setNFlag(1)
		}
	case .DAA:
		daa()
	case .RLCA:
		{
			carry := (getUpperRegister(cpu.register.AF) >> 7) & 0x01
			setUpperRegister(&cpu.register.AF, getUpperRegister(cpu.register.AF) << 1 | carry)
			setCFlag(carry)
			setHFlag(0)
			setNFlag(0)
			setZFlag(0)
		}
	case .RLA:
		{
			carry := (getUpperRegister(cpu.register.AF) >> 7) & 0x01
			setUpperRegister(&cpu.register.AF, getUpperRegister(cpu.register.AF) << 1 | getCFlag())
			setCFlag(carry)
			setHFlag(0)
			setNFlag(0)
			setZFlag(0)
		}
	case .RRA:
		{
			carry := getUpperRegister(cpu.register.AF) & 0x01
			setUpperRegister(
				&cpu.register.AF,
				getUpperRegister(cpu.register.AF) >> 1 | (getCFlag() << 7),
			)
			setCFlag(carry)
			setHFlag(0)
			setNFlag(0)
			setZFlag(0)
		}
	case .RRCA:
		{
			carry := getUpperRegister(cpu.register.AF) & 0x01
			setUpperRegister(&cpu.register.AF, getUpperRegister(cpu.register.AF) >> 1 | carry << 7)
			setCFlag(carry)
			setHFlag(0)
			setNFlag(0)
			setZFlag(0)
		}
	case .STOP:
	case .NOP:
	case:
		fmt.printfln(
			"No valid instruction found: %02X | %v",
			cpu.currentOpCode,
			currentInstruction,
		)
		os.exit(1)
	}

	if cpu.currentOpCode != 0 {

		fmt.printfln(printRegToHex())
	}

	cpu.register.PC += cpu.currentInstruction.lenght + 1

}

load_register_num :: proc(register: RegisterType, data: u16, half: registerHalf) {

	#partial switch half {
	case .ALL:
		getRegisterFromType(register)^ = data
	case .UPPER:
		setUpperRegister(getRegisterFromType(register), u8(data))
	case .LOWER:
		setLowerRegister(getRegisterFromType(register), u8(data))
	}
}


load_register_register :: proc(
	register, register2: RegisterType,
	half, half2: registerHalf,
	data: u16,
) {

	reg := getRegisterFromType(register)
	reg2 := getRegisterFromType(register2)
	value: u8

	#partial switch half2 {
	case .UPPER:
		value = getUpperRegister(reg2^)
	case .LOWER:
		value = getLowerRegister(reg2^)
	}

	#partial switch half {
	case .UPPER:
		setUpperRegister(reg, value)
	case .LOWER:
		setLowerRegister(reg, value)
	}

	if register == RegisterType.HL && register2 == RegisterType.SP {
		value1 := cpu.register.HL
		value2 := cpu.register.SP + data
		cpu.register.HL = value1 + value2
		hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
		cCarry: bool = value1 + value2 < value1
		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		setZFlag(0)
	}

	if register == RegisterType.SP && register2 == RegisterType.HL {
		cpu.register.SP = cpu.register.HL
	}

}


load_memory_register_or_num :: proc(
	register, register2: RegisterType,
	data: u16,
	half: registerHalf,
) {
	reg := getRegisterFromType(register)
	reg2 := getRegisterFromType(register2)

	fmt.println("Loading to memory address: ", reg^)
	fmt.println(
		"Loading value from register: ",
		getUpperRegister(reg2^),
		" | ",
		getLowerRegister(reg2^),
		" | ",
		u8(data),
	)


	#partial switch half {
	case .UPPER:
		writeMem(reg^, getUpperRegister(reg2^))
	case .LOWER:
		writeMem(reg^, getLowerRegister(reg2^))
	case .NONE:
		writeMem(reg^, u8(data))
	}

	addrMode := cpu.currentInstruction.addrMode
	if addrMode == InstructionMode.HLI_R {
		cpu.register.HL += 1
	}
	if addrMode == InstructionMode.HLD_R {
		cpu.register.HL -= 1
	}

	fmt.printfln("Memory: %02X", memory[reg^])
		
}

loadH_memory_register_or_num :: proc(register: RegisterType, data: u16) {
	reg := getRegisterFromType(register)
	regA := getUpperRegister(cpu.register.AF)


	if data >= 0xFF00 || data <= 0xFFFF && register == RegisterType.NONE {
		writeMem(data, regA)
		return
	}

	regC := getLowerRegister(cpu.register.PC)

	writeMem(0xFF00 + u16(regC), regA)


}

loadH_register_memory :: proc(register: RegisterType, data: u16) {
	reg := getRegisterFromType(register)
	regA := getUpperRegister(cpu.register.AF)


	if data >= 0xFF00 || data <= 0xFFFF && register == RegisterType.NONE {
		setUpperRegister(reg, memory[data])
		return
	}

	regC := getLowerRegister(cpu.register.PC)

	setUpperRegister(reg, memory[regC])


}

load_at_memory_register :: proc(register2: RegisterType, data: u16, half: registerHalf) {

	reg2 := getRegisterFromType(register2)

	#partial switch half {
	case .UPPER:
		writeMem(data, getUpperRegister(reg2^))
	case .ALL:
		writeMem(data, u8(cpu.register.SP & 0xFF))
		writeMem(data + 1, u8((cpu.register.SP >> 8)))
	}

	fmt.printfln("Memory: %04X", data)

}

load_register_memory :: proc(register, register2: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)
	reg2 := getRegisterFromType(register2)

	#partial switch half {
	case .UPPER:
		setUpperRegister(&cpu.register.AF, readMem(reg2^))
	case .LOWER:
		setLowerRegister(&cpu.register.AF, readMem(reg2^))
	}

	addrMode := cpu.currentInstruction.addrMode
	if addrMode == InstructionMode.R_HLI {
		cpu.register.HL += 1
	}
	if addrMode == InstructionMode.R_HLD {
		cpu.register.HL -= 1
	}
}


inc_register :: proc(register: RegisterType, half: registerHalf) {
	reg := getRegisterFromType(register)
	#partial switch half {
	case .ALL:
		reg^ += 1
	case .UPPER:
		{
			value := getUpperRegister(reg^) + 1
			hCarry: bool = ((getUpperRegister(reg^) & 0x0F) + (0x1 & 0x0F)) > 0x0F
			setHFlag(hCarry ? 1 : 0)
			setUpperRegister(reg, value)
			setNFlag(0)
			if value == 0 {
				setZFlag(0)
			}
		}
	case .LOWER:
		{
			value := getLowerRegister(reg^) + 1
			hCarry: bool = ((getLowerRegister(reg^) & 0x0F) + (0x1 & 0x0F)) > 0x0F
			setHFlag(hCarry ? 1 : 0)
			setLowerRegister(reg, value)
			setNFlag(0)
			if value == 0 {
				setZFlag(0)
			}
		}
	}
}

inc_memory :: proc(register: RegisterType, half: registerHalf) {
	reg := getRegisterFromType(register)^
	#partial switch half {

	case .ALL:
		{
			orgMem := readMem(reg)
			newValue := orgMem + 1
			hcarry := (newValue & 0x0F) == 0x00
			writeMem(reg, newValue)
			setHFlag(hcarry ? 1 : 0)
			setNFlag(0)
			setZFlag(newValue == 0 ? 1 : 0)

		}
	}


}


daa :: proc() {

	aReg := cpu.register.AF

	adjustment: u8

	if getNFlag() == 1 {
		adjustment = 0
		if getHFlag() == 1 {
			adjustment += 0x6
		}
		if getCFlag() == 1 {
			adjustment += 0x60
		}
		setUpperRegister(&cpu.register.AF, getUpperRegister(aReg) - adjustment)
	} else {
		adjustment = 0
		if getHFlag() == 1 || (getUpperRegister(aReg) & 0xF > 0x9) {
			adjustment += 0x6
		}
		if getCFlag() == 1 || (getUpperRegister(aReg) > 0x99) {
			adjustment += 0x60
			setCFlag(1)
		}
		setUpperRegister(&cpu.register.AF, getUpperRegister(aReg) + adjustment)

	}
	setHFlag(0)
	if getUpperRegister(aReg) == 0 {
		setZFlag(0)
	}
}

dec_register :: proc(register: RegisterType, half: registerHalf) {
	reg := getRegisterFromType(register)
	#partial switch half {
	case .ALL:
		reg^ -= 1
	case .UPPER:
		{
			hcarry := (reg^ & 0x0F) == 0x00
			setHFlag(hcarry ? 1 : 0)

			value := getUpperRegister(reg^) - 1
			setNFlag(1)
			if value == 0 {
				setZFlag(1)
			}
			setUpperRegister(reg, value)
		}
	case .LOWER:
		{
			hcarry := (reg^ & 0x0F) == 0x00
			setHFlag(hcarry ? 1 : 0)
			value := getLowerRegister(reg^) - 1
			setNFlag(1)
			if value == 0 {
				setZFlag(1)
			}
			setLowerRegister(reg, value)

		}
	}
}

dec_memory :: proc(register: RegisterType, half: registerHalf) {
	reg := getRegisterFromType(register)^
	#partial switch half {

	case .ALL:
		{
			orgMem := readMem(reg)
			newValue := orgMem - 1
			hcarry := (newValue & 0x0F) == 0x00
			writeMem(reg, newValue)
			setHFlag(hcarry ? 1 : 0)
			setNFlag(1)
			setZFlag(newValue == 0 ? 1 : 0)
		}
	}
}

add_register_register :: proc(register1, register2: RegisterType, half1, half2: registerHalf) {

	reg := getRegisterFromType(register1)
	reg2 := getRegisterFromType(register2)

	#partial switch half2 {
	case .UPPER:
		value1 := getUpperRegister(cpu.register.AF)
		value2 := getUpperRegister(reg2^)

		hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
		cCarry: bool = value1 + value2 < value1
		zCarry: bool = value1 + value2 == 0
		setUpperRegister(&cpu.register.AF, value1 + value2)
		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		setZFlag(zCarry ? 1 : 0)
	case .LOWER:
		value1 := getUpperRegister(cpu.register.AF)
		value2 := getLowerRegister(reg2^)

		hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
		cCarry: bool = value1 + value2 < value1
		zCarry: bool = value1 + value2 == 0
		setUpperRegister(&cpu.register.AF, value1 + value2)
		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		setZFlag(zCarry ? 1 : 0)

	case .ALL:
		hCarry: bool = (reg^ & 0x0FFF) + (reg^ & 0x0FFF) > 0x0FFF
		cCarry: bool = reg^ + reg2^ < reg^

		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		reg^ += reg2^
	}


}

and_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)^
	reghalf: u8

	#partial switch half {
	case .UPPER:
		reghalf = getUpperRegister(reg)
	case .LOWER:
		reghalf = getLowerRegister(reg)
	}
	result := getUpperRegister(cpu.register.AF) & reghalf
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(1)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

and_register_memory :: proc() {

	result := getUpperRegister(cpu.register.AF) & memory[cpu.register.HL]
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(1)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

xor_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)^
	reghalf: u8

	#partial switch half {
	case .UPPER:
		reghalf = getUpperRegister(reg)
	case .LOWER:
		reghalf = getLowerRegister(reg)
	}
	result := getUpperRegister(cpu.register.AF) ~ reghalf
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(0)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

xor_register_memory :: proc() {

	result := getUpperRegister(cpu.register.AF) ~ memory[cpu.register.HL]
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(0)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}


or_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)^
	reghalf: u8

	#partial switch half {
	case .UPPER:
		reghalf = getUpperRegister(reg)
	case .LOWER:
		reghalf = getLowerRegister(reg)
	}
	result := getUpperRegister(cpu.register.AF) | reghalf
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(0)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

or_register_num :: proc(data: u16) {

	result := getUpperRegister(cpu.register.AF) | u8(data)
	setUpperRegister(&cpu.register.AF, result)
	setCFlag(0)
	setHFlag(0)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

or_register_memory :: proc() {

	result := getUpperRegister(cpu.register.AF) | memory[cpu.register.HL]
	setUpperRegister(&cpu.register.AF, result)

	setCFlag(0)
	setHFlag(0)
	setNFlag(0)
	setZFlag(result == 0 ? 1 : 0)

}

cp_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)^
	reghalf: u8
	value := getUpperRegister(cpu.register.AF)

	#partial switch half {
	case .UPPER:
		reghalf = getUpperRegister(reg)
	case .LOWER:
		reghalf = getLowerRegister(reg)
	}
	result := value - reghalf
	cCarry: bool = value - reghalf < value
	hCarry: bool = (reghalf & 0x0F) - (value & 0x0F) > 0x0F

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(1)
	setZFlag(result == 0 ? 1 : 0)

}

cp_register_memory :: proc() {
	value := getUpperRegister(cpu.register.AF)
	value2 := memory[cpu.register.HL]
	result := value - value2

	cCarry: bool = value - value2 < value
	hCarry: bool = (value2 & 0x0F) - (value & 0x0F) > 0x0F

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(1)
	setZFlag(result == 0 ? 1 : 0)

}

cp_register_num :: proc(data: u16) {
	value := getUpperRegister(cpu.register.AF)
	value2 := u8(data)
	result := value - value2

	cCarry: bool = value - value2 < value
	hCarry: bool = (value2 & 0x0F) - (value & 0x0F) > 0x0F

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(1)
	setZFlag(result == 0 ? 1 : 0)

}


add_register_memory :: proc(data: u16) {

	reg := cpu.register.AF
	value1 := getUpperRegister(cpu.register.AF)
	value2 := memory[data]

	hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 + value2 < value1
	zCarry: bool = value1 + value2 == 0
	setUpperRegister(&cpu.register.AF, value1 + value2)
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)


}


add_a_n8 :: proc(data: u16) {
	value1 := getUpperRegister(cpu.register.AF)
	value2 := u8(data)

	hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 + value2 < value1
	zCarry: bool = value1 + value2 == 0
	setUpperRegister(&cpu.register.AF, value1 + value2)
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
}

add_sp_e8 :: proc(data: u16) {

	sp := cpu.register.SP
	e8 := i16(i8(u8(data)))

	hCarry := (i16(sp & 0x000F) + (e8 & 0x000F)) > 0x0F
	cCarry := (i16(sp & 0x00FF) + (e8 & 0x00FF)) > 0xFF
	zCarry: bool = sp + u16(e8) == 0
	cpu.register.SP = u16(i16(sp) + e8)

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(0)
}

sub_register_register :: proc(register1, register2: RegisterType, half1, half2: registerHalf) {

	reg := getRegisterFromType(register1)
	reg2 := getRegisterFromType(register2)

	#partial switch half2 {
	case .UPPER:
		value1 := getUpperRegister(cpu.register.AF)
		value2 := getUpperRegister(reg2^)

		hCarry: bool = ((value1 & 0x0F) < (value2 & 0x0F))
		cCarry: bool = value1 - value2 < value1
		zCarry: bool = value1 - value2 == 0
		setUpperRegister(&cpu.register.AF, value1 - value2)
		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		setZFlag(zCarry ? 1 : 0)
	case .LOWER:
		value1 := getUpperRegister(cpu.register.AF)
		value2 := getLowerRegister(reg2^)

		hCarry: bool = ((value1 & 0x0F) - (value2 & 0x0F)) > 0x0F
		cCarry: bool = value1 - value2 < value1
		zCarry: bool = value1 - value2 == 0
		setUpperRegister(&cpu.register.AF, value1 - value2)
		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		setZFlag(zCarry ? 1 : 0)

	case .ALL:
		hCarry: bool = (reg^ & 0x0FFF) - (reg^ & 0x0FFF) > 0x0FFF
		cCarry: bool = reg^ - reg2^ < reg^

		setCFlag(cCarry ? 1 : 0)
		setHFlag(hCarry ? 1 : 0)
		setNFlag(0)
		reg^ -= reg2^
	}
}

sub_register_memory :: proc(data: u16) {

	reg := cpu.register.AF
	value1 := getUpperRegister(cpu.register.AF)
	value2 := memory[data]

	hCarry: bool = ((value1 & 0x0F) - (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 - value2 < value1
	zCarry: bool = value1 - value2 == 0
	setUpperRegister(&cpu.register.AF, value1 - value2)
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)


}

adc_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)
	value1 := getUpperRegister(cpu.register.AF)
	value2: u8
	#partial switch half {
	case .LOWER:
		value2 = value1 + getLowerRegister(reg^) + getCFlag()
	case .UPPER:
		value2 = value1 + getUpperRegister(reg^) + getCFlag()

	}

	hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 + value2 < value1
	zCarry: bool = value1 + value2 == 0

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}


adc_register_data :: proc(half: registerHalf, data: u16) {

	value1 := getUpperRegister(cpu.register.AF)


	value2 := value1 + u8(data) + (getUpperRegister(cpu.register.AF) & 0x10)
	hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 + value2 < value1
	zCarry: bool = value1 + value2 == 0
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}

adc_register_memory :: proc(half: registerHalf) {

	value1 := getUpperRegister(cpu.register.AF)
	value2 := value1 + memory[cpu.register.HL] + (getUpperRegister(cpu.register.AF) & 0x10)

	hCarry: bool = ((value1 & 0x0F) + (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 + value2 < value1
	zCarry: bool = value1 + value2 == 0
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}

sbc_register_register :: proc(register: RegisterType, half: registerHalf) {

	reg := getRegisterFromType(register)
	value1 := getUpperRegister(cpu.register.AF)
	value2: u8
	#partial switch half {
	case .LOWER:
		value2 = value1 - getLowerRegister(reg^) - getCFlag()
	case .UPPER:
		value2 = value1 - getUpperRegister(reg^) - getCFlag()
	}

	hCarry: bool = ((value1 & 0x0F) - (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 - value2 < value1
	zCarry: bool = value1 - value2 == 0

	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}


sbc_register_data :: proc(half: registerHalf, data: u16) {

	value1 := getUpperRegister(cpu.register.AF)

	value2 := value1 - u8(data) - (getUpperRegister(cpu.register.AF) & 0x10)
	hCarry: bool = ((value1 & 0x0F) - (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 - value2 < value1
	zCarry: bool = value1 - value2 == 0
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}

sbc_register_memory :: proc(half: registerHalf) {

	value1 := getUpperRegister(cpu.register.AF)
	value2 := value1 - memory[cpu.register.HL] - (getUpperRegister(cpu.register.AF) & 0x10)

	hCarry: bool = ((value1 & 0x0F) - (value2 & 0x0F)) > 0x0F
	cCarry: bool = value1 - value2 < value1
	zCarry: bool = value1 - value2 == 0
	setCFlag(cCarry ? 1 : 0)
	setHFlag(hCarry ? 1 : 0)
	setNFlag(0)
	setZFlag(zCarry ? 1 : 0)
	setUpperRegister(&cpu.register.AF, value2)
}

jr_e8 :: proc(data: u16, cc: conditionCode) {
	do_jump := false

	if (cc == conditionCode.NZ && getZFlag() == 0) ||
	   (cc == conditionCode.Z && getZFlag() == 1) ||
	   (cc == conditionCode.C && getCFlag() == 1) ||
	   (cc == conditionCode.NC && getCFlag() == 0) ||
	   cc == conditionCode.NONE {
		do_jump = true
	}

	if do_jump {
		offset := i16(i8(u8(data)))
		cpu.register.PC = cpu.register.PC + 2 + u16(offset)
	} else {
		cpu.register.PC += 2
	}
}

jp_n16 :: proc(data: u16, cc: conditionCode) {

	if (cc == conditionCode.NZ && getZFlag() == 0) ||
	   (cc == conditionCode.Z && getZFlag() == 1) ||
	   (cc == conditionCode.C && getCFlag() == 1) ||
	   (cc == conditionCode.NC && getCFlag() == 0) ||
	   cc == conditionCode.NONE {
		cpu.register.PC = data
	} else {
		cpu.register.PC += 2
	}
}

pop_register :: proc(register: RegisterType) {

	reg := getRegisterFromType(register)

	regUpper := getUpperRegister(reg^)
	regLower := getLowerRegister(reg^)


	regLower = memory[cpu.register.SP]
	cpu.register.SP += 1
	regUpper = memory[cpu.register.SP]
	cpu.register.SP += 1

	if register == RegisterType.AF {
		setCFlag((regLower & 0x10) >> 4)
		setHFlag((regLower & 0x20) >> 5)
		setNFlag((regLower & 0x40) >> 6)
		setZFlag((regLower & 0x80) >> 7)
	}
}


ret_cc :: proc(cc: conditionCode) {
	if (cc == conditionCode.NZ && getZFlag() == 0) ||
	   (cc == conditionCode.Z && getZFlag() == 1) ||
	   (cc == conditionCode.C && getCFlag() == 1) ||
	   (cc == conditionCode.NC && getCFlag() == 0) ||
	   cc == conditionCode.NONE {

		lower := memory[cpu.register.SP]
		cpu.register.SP += 1

		upper := memory[cpu.register.SP]
		cpu.register.SP += 1

		cpu.register.PC = u16(lower) | (u16(upper) << 8)
	}
}

reti_cc :: proc(cc: conditionCode) {

	setLowerRegister(&cpu.register.PC, memory[cpu.register.SP])
	cpu.register.SP += 1
	setUpperRegister(&cpu.register.PC, memory[cpu.register.SP])

	// TODO: setting interrupts enabled

}

call_cc :: proc(data: u16, cc: conditionCode) {

	if (cc == conditionCode.NZ && getZFlag() == 0) ||
	   (cc == conditionCode.Z && getZFlag() == 1) ||
	   (cc == conditionCode.C && getCFlag() == 1) ||
	   (cc == conditionCode.NC && getCFlag() == 0) ||
	   cc == conditionCode.NONE {
		memory[cpu.register.SP - 1] = getLowerRegister(cpu.register.PC)
		memory[cpu.register.SP - 2] = getUpperRegister(cpu.register.PC)
		cpu.register.SP -= 2
		cpu.register.PC = data
	}
}

push_register :: proc(register: RegisterType) {
	reg := getRegisterFromType(register)

	regUpper := getUpperRegister(reg^)
	regLower := getLowerRegister(reg^)

	cpu.register.SP -= 1
	memory[cpu.register.SP] = regLower
	cpu.register.SP -= 1
	memory[cpu.register.SP] = regUpper

}

rst :: proc(data: u16) {
	cpu.register.SP -= 1
	memory[cpu.register.SP] = getLowerRegister(cpu.register.PC)
	cpu.register.SP -= 1
	memory[cpu.register.SP] = getUpperRegister(cpu.register.PC)
	cpu.register.PC = data
}
