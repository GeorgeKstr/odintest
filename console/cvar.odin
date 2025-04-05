package console

import "core:fmt"
import sto "core:strconv"
import "../console"
import "core:strings"

cvarType :: enum { bool, int, float, string }

cvarValue :: union {
    bool,
    int,
    f32,
    string,
}

cvar :: struct {
    name: string,
    type: cvarType,
    value: cvarValue,
    defaultValue: cvarValue,
    description: string, // Optional: for help/info
    flags: u32,          // Flags for read-only, cheats, etc.
}

command :: struct {
    name: string,
    description: string, // Optional: for help/info
    execute: proc(args: []string),
    argsCount: u32,     // Number of arguments this command expects
}

Registry :: struct {
    cvars: map[string]cvar,
    commands: map[string]command, // Command name to Command object
}

cvarRegistry := Registry{}

registerCvar :: proc(name: string, type: cvarType, default_value, description: string) {
    cvar := cvar{
        name = name,
        type = type,
        value = default_value,
        defaultValue = default_value,
        description = description,
    }
    cvarRegistry.cvars[name] = cvar
    log("Registered cvar: [", name, "]")
}

setCvar :: proc(name: string, value: string) {
    cvar, found := cvarRegistry.cvars[name]
    if !found {
        log_error("Error: Cvar [", name, "] not found")
        return
    }
    switch cvar.type {
    case cvarType.bool:
        val, err := sto.parse_bool(value)
        if err != true {
            cvar.value = val
        } else {
            log_error("Invalid value for cvar [", cvar.name, "]: '", value, "', expected: boolean")
            cvar.value = cvar.defaultValue
        }
    case cvarType.float:
        val, err := sto.parse_f32(value, nil)
        if err != true {
            cvar.value = val
        } else {
            log_error("Invalid value for cvar [", cvar.name, "]: '", value, "', expected: float")
            cvar.value = cvar.defaultValue
        }
    case cvarType.int:
        val, err := sto.parse_int(value)
        if err != true {
            cvar.value = val
        } else {
            log_error("Invalid value for cvar [", cvar.name, "]: '", value, "', expected: integer")
            cvar.value = cvar.defaultValue
        }
    case cvarType.string:
        cvar.value = value
    
    }
}

getCvar :: proc(name: string) -> ^cvar {
    if !(name in cvarRegistry.cvars) {
        return nil
    }
    return &cvarRegistry.cvars[name]
}

registerCommand :: proc(name: string, execute: proc(args: []string), description: string, argsCount: u32) {
    command := command{
        name = name,
        execute = execute,
        description = description,
        argsCount = argsCount,
    }
    cvarRegistry.commands[name] = command
    log("Registered command: [", name, "]")
}

executeCommand :: proc(input: string) {
    tokens := strings.split(input, " ") // Split input into command and args
    commandName := tokens[0]
    args := tokens[1:]
    if !(commandName in cvarRegistry.commands) {
        log_error("Error: Command: [", commandName, "] not found")
        return
    }
    command := cvarRegistry.commands[commandName]
    if len(args) != int(command.argsCount) {
        log_error("Error: Command [", commandName, "] expects ", command.argsCount, " arguments, but got ", len(args))
        return
    }
    command.execute(args)
}

isCommand :: proc(name: string) -> bool {
    return name in cvarRegistry.commands
}

clearConsole :: proc() {
    fmt.println("All data cleared from registry")
}


