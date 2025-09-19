# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Run Commands
- Build: `odin build src -out:bin/GBEmulator`
- Run: Execute the binary in the bin directory
- Test: Load test ROMs using the loadCartridge function (e.g., `loadCartridge("tests/03.gb")`)

## Code Style Guidelines
- Package: All files use `package main`
- Imports: Format as `import name "core:package"` (e.g., `import fmt "core:fmt"`)
- Constants: Use `::` syntax (e.g., `WINDOW_HEIGHT :: 1152`)
- Naming: Use snake_case for procedures and variables, PascalCase for structs
- Types: Use explicit types like `u8`, `u16` for GameBoy-specific registers
- Procedures: Format as `proc_name :: proc(params) -> return_type`
- Memory Access: Use `readMem`/`writeMem` procedures for memory interactions
- Error Handling: Use simple if statements with fmt.println for error messaging