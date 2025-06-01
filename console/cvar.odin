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
    isRemote: bool,
}

command :: struct {
    name: string,
    description: string, // Optional: for help/info
    execute: proc(args: []string),
    argsCount: u32,     // Number of arguments this command expects
    isRemote: bool,
}

Registry :: struct {
    cvars: map[string]^cvar,
    commands: map[string]^command, // Command name to Command object
}

cvarRegistry := Registry{}

registerCvar :: proc(name: string, type: cvarType, default_value, description: string, isRemote: bool = false) {
    cvar2 := new(cvar)
    cvar2.name = name
    cvar2.type = type
    cvar2.value = default_value
    cvar2.defaultValue = default_value
    cvar2.description = description
    cvar2.isRemote = isRemote
    cvarRegistry.cvars[name] = cvar2
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
    return cvarRegistry.cvars[name]
}

registerCommand :: proc(name: string, execute: proc(args: []string), description: string, argsCount: u32, isRemote: bool = false) {
    command2 := new(command)
    command2.name = name
    command2.description = description
    command2.execute = execute
    command2.argsCount = argsCount
    command2.isRemote = isRemote
    cvarRegistry.commands[name] = command2
    log("Registered command: [", name, "]")
}

executeCommand :: proc(input: string) {
    tokens := strings.split(input, " ", context.temp_allocator) // Split input into command and args
    commandName := tokens[0]
    args := tokens[1:]
    if !(commandName in cvarRegistry.commands) {
        log_error("Error: Command: [", commandName, "] not found")
        return
    }
    commandaddr := cvarRegistry.commands[commandName]
    command := commandaddr^
    if int(command.argsCount)!=999 && len(args) != int(command.argsCount) {
        log_error("Error: Command [", commandName, "] expects ", command.argsCount, " arguments, but got ", len(args))
        return
    }
    command.execute(args)
    free_all(context.temp_allocator)
}

isCommand :: proc(name: string) -> bool {
    if name in cvarRegistry.commands {
        return true
    }  
    return false
}

initializeRegistry :: proc() {
    cvarRegistry.cvars = make(map[string]^cvar)
    cvarRegistry.commands = make(map[string]^command)
}

clearRegistry :: proc() {
    for _, &v in cvarRegistry.cvars {
        free (v)
    }
    clear(&cvarRegistry.cvars)
    for _, &v2 in cvarRegistry.commands {
        free(v2)
    }
    delete(cvarRegistry.commands)
    for _, &v2 in cvarRegistry.commands {
        fmt.println("malakia", v2.name)
    }
}