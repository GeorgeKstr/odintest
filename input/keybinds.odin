package input

import rl "vendor:raylib"
import "core:fmt"

user_action::enum{
    ACTION_FIRE,
    ACTION_FORWARD,
    ACTION_BACKWARD,
    ACTION_LEFT,
    ACTION_RIGHT,
    ACTION_UP,
    ACTION_DOWN,
    ACTION_JUMP,
    ACTION_CROUCH,
    ACTION_ATTACK,
    ACTION_BLOCK,
    ACTION_USE,
    ACTION_INVENTORY,
    ACTION_PAUSE,
    ACTION_CONSOLE,
    ACTION_QUIT,
}

action_names := map[string]user_action{
    "FIRE" = user_action.ACTION_FIRE,
    "FORWARD" = user_action.ACTION_FORWARD,
    "BACKWARD" = user_action.ACTION_BACKWARD,
    "LEFT" = user_action.ACTION_LEFT,
    "RIGHT" = user_action.ACTION_RIGHT,
    "UP" = user_action.ACTION_UP,
    "DOWN" = user_action.ACTION_DOWN,
    "JUMP" = user_action.ACTION_JUMP,
    "CROUCH" = user_action.ACTION_CROUCH,
    "ATTACK" = user_action.ACTION_ATTACK,
    "BLOCK" = user_action.ACTION_BLOCK,
    "USE" = user_action.ACTION_USE,
    "INVENTORY" = user_action.ACTION_INVENTORY,
    "PAUSE" = user_action.ACTION_PAUSE,
    "CONSOLE" = user_action.ACTION_CONSOLE,
    "QUIT" = user_action.ACTION_QUIT,
}

key_map := map[string]rl.KeyboardKey{
    "UP" = .UP,
    "DOWN" = .DOWN,
    "LEFT" = .LEFT,
    "RIGHT" = .RIGHT,
    "ENTER" = .ENTER,
    "ESCAPE" = .ESCAPE,
    "SPACE" = .SPACE,
    "LALT" = .LEFT_ALT,
    "LCTRL" = .LEFT_CONTROL,
    "LSHIFT" = .LEFT_SHIFT,
    "RALT" = .RIGHT_ALT,
    "RCTRL" = .RIGHT_CONTROL,
    "RSHIFT" = .RIGHT_SHIFT,
    "HOME" = .HOME,
    "END" = .END,
    "INSERT" = .INSERT,
    "DELETE" = .DELETE,
    "PAGEUP" = .PAGE_UP,
    "PAGEDOWN" = .PAGE_DOWN,
    "F1" = .F1,
    "F2" = .F2,
    "F3" = .F3,
    "F4" = .F4,
    "F5" = .F5,
    "F6" = .F6,
    "F7" = .F7,
    "F8" = .F8,
    "F9" = .F9,
    "F10" = .F10,
    "F11" = .F11,
    "F12" = .F12,
    "A" = .A,
    "B" = .B,
    "C" = .C,
    "D" = .D,
    "E" = .E,
    "F" = .F,
    "G" = .G,
    "H" = .H,
    "I" = .I,
    "J" = .J,
    "K" = .K,
    "L" = .L,
    "M" = .M,
    "N" = .N,
    "O" = .O,
    "P" = .P,
    "Q" = .Q,
    "R" = .R,
    "S" = .S,
    "T" = .T,
    "U" = .U,
    "V" = .V,
    "W" = .W,
    "X" = .X,
    "Y" = .Y,
    "Z" = .Z,
}

mouse_button_map := map[string]rl.MouseButton{
    "MOUSE_LEFT" = .LEFT,
    "MOUSE_RIGHT" = .RIGHT,
    "MOUSE_MIDDLE" = .MIDDLE
}

mouse_button_keybinds := make(map[rl.MouseButton]user_action)
button_keybinds := make(map[rl.KeyboardKey]user_action)
key_pending: bool = false

bindKeyToAction := proc(key: string, action: user_action) {
    if key in key_map {
        k := key_map[key]
        button_keybinds[k] = action
    } else if key in mouse_button_map {
        k := mouse_button_map[key]
        mouse_button_keybinds[k] = action
    }
    else{
        fmt.println("Unknown key: ", key)
    }
}

checkMouseButtons := proc() {
    for button, action in mouse_button_keybinds {
        if rl.IsMouseButtonPressed(button) {
            handleInput(action, true)
        } else if rl.IsMouseButtonReleased(button) {
            handleInput(action, false)
        }
    }
}

checkKeyboard := proc() {
    for key, action in button_keybinds {
        if rl.IsKeyPressed(key) {
            handleInput(action, true)
        } else if rl.IsKeyReleased(key) {
            handleInput(action, false)
        }
        
    }
}

checkInput := proc() {
    mousepos := rl.GetMousePosition()
    checkKeyboard()
    checkMouseButtons()
}

clearInput := proc() {
    clear(&key_map)
    clear(&button_keybinds)
}
