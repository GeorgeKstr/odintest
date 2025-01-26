package console

import "core:fmt"
import sto "core:strconv"
import "core:strings"

CvarType :: enum { Bool, Int, Float, String }

CvarValue :: union {
    bool,
    int,
    f32,
    string,
}

Cvar :: struct {
    name: string,
    type: CvarType,
    value: CvarValue,
    defaultValue: CvarValue,
    description: string, // Optional: for help/info
    flags: u32,          // Flags for read-only, cheats, etc.
}

Command :: struct {
    name: string,
    description: string, // Optional: for help/info
    execute: proc(args: []string),
}

CvarRegistry :: struct {
    cvars: map[string]Cvar,
    commands: map[string]Command, // Command name to Command object
}

RegisterCvar :: proc(registry: ^CvarRegistry, name: string, type: CvarType, default_value, description: string) {
    cvar := Cvar{
        name = name,
        type = type,
        value = default_value,
        defaultValue = default_value,
        description = description,
    };
    registry.cvars[name] = cvar;
    fmt.println("Registered cvar: {}", name);
}

SetCvar :: proc(registry: ^CvarRegistry, name: string, value: string) {
    cvar, found := registry.cvars[name];
    if !found {
        fmt.println("Error: Cvar '{name}' not found.");
        return;
    }
    switch cvar.type {
    case CvarType.Bool:
        val, err := sto.parse_bool(value);
        if err!=true {
            cvar.value=val;
        }
        else {
            fmt.println("Invalid value for cvar '%s': '%s', expected: boolean", cvar.name, value);
            cvar.value = cvar.defaultValue;
        }
    case CvarType.Float:
        val, err := sto.parse_f32(value, nil);
        if err!=true {
            cvar.value = val;
        } else {
            fmt.println("Invalid value for cvar '%s': '%s', expected: float", cvar.name, value);
            cvar.value = cvar.defaultValue;
        }
    case CvarType.Int:
        val, err := sto.parse_int(value);
        if err!=true {
            cvar.value = val;
        } else {
            fmt.println("Invalid value for cvar '%s': '%s', expected: integer", cvar.name, value);
            cvar.value = cvar.defaultValue;
        }
    case CvarType.String:
        cvar.value = value;
    
    }
}

GetCvar :: proc(registry: ^CvarRegistry, name: string) -> ^Cvar {
    if !(name in registry.cvars) {
        return nil;
    }
    return &registry.cvars[name];
}

RegisterCommand :: proc(registry: ^CvarRegistry, name: string, execute: proc(args: []string), description: string) {
    command := Command{
        name = name,
        execute = execute,
        description = description,
    };
    registry.commands[name] = command;
    fmt.println("Registered command: {}", name);
}

ExecuteCommand :: proc(registry: ^CvarRegistry, input: string) {
    tokens := strings.split(input, " "); // Split input into command and args
    command_name := tokens[0];
    args := tokens[1:]

    if !(command_name in registry.commands) {
        fmt.println("Error: Command '%s' not found.", command_name);
        return;
    }
    command := registry.commands[command_name];
    command.execute(args);
}
