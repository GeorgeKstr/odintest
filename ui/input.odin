package ui
import rl "vendor:raylib"
import "core:fmt"
import "../console"

handleInput := proc(keyname: string, action: user_action, pressed: bool) {
    w := windows_head
    if rl.IsKeyPressed(.GRAVE) {
        create_console()
        return
    }
    if cursor_enabled {
        if rl.IsKeyPressed(.K) {
            rl.SetWindowSize(800, 600)
        }
        left, right, wheel := false, false, false
        if rl.IsMouseButtonPressed(.LEFT) || rl.IsMouseButtonReleased(.LEFT) {
            left = true
        } else if rl.IsMouseButtonPressed(.RIGHT) || rl.IsMouseButtonReleased(.RIGHT) {
            right = true
        }
        if left || right {
            if(pressed){
                w:=hover_window
                if(w==nil){
                    return
                }
                makeHead(w)
                if(isPointInsideHeader(mousepos, w) && left){
                    if mousepos.x >= w.content_origin.x+w.content_size.x-headersize {
                        closeWindow(w)
                        hover_window = nil
                        return
                    }
                    move_mode=.MOVE_MOVE
                    move_offset=w.content_origin - mousepos
                    move_offset.y-=headersize
                } else{
                    if left {
                        move_mode=.MOVE_NONE
                        if mousepos.x <= w.content_origin.x+edgesize && mousepos.y >= w.content_origin.y + w.content_size.y - edgesize - headersize{
                            move_offset = mousepos - w.content_origin - {0, w.content_size.y}
                            move_mode=.MOVE_RESIZE_LEFT
                        } else if mousepos.x >= w.content_origin.x+w.content_size.x-edgesize && mousepos.y >= w.content_origin.y + w.content_size.y - edgesize - headersize {
                            move_offset = mousepos - w.content_origin - w.content_size
                            move_mode=.MOVE_RESIZE_RIGHT
                        } else {
                            focused_component = nil
                            for c:=w.components;c!=nil;c=c.next{
                                if(isPointInsideBox(mousepos, c.content_origin, c.content_size)){
                                    focused_component = c
                                    c.input(c, action, pressed)
                                    break
                                }
                            }
                        }
                    } else if right {
                        focused_component = nil
                        for c:=w.components;c!=nil;c=c.next{
                            if(isPointInsideBox(mousepos, c.content_origin, c.content_size)){
                                focused_component = c
                                c.input(c, action, pressed)
                                break
                            }
                        }
                    }
                }
            } else{
                move_mode=.MOVE_NONE
                if focused_component!=nil{
                    focused_component.input(focused_component, action, pressed)
                }
            }
        } else if rl.GetMouseWheelMove() != 0 && hover_window!=nil {
            focused_component = nil
            for c:=w.components;c!=nil;c=c.next{
                if(isPointInsideBox(mousepos, c.content_origin, c.content_size)){
                    focused_component = c
                    if c.args[carg.SCROLL] != nil && c.args[carg.SCROLL].(bool){
                        c.input(c, action, pressed)
                        return
                    }
                    break
                }
            }
            w:=hover_window
            if(w.scrollable){
                w.scroll = rl.Clamp(w.scroll - rl.GetMouseWheelMove()*0.02, 0.0, 1.0)
            }
        } else{
            if(focused_component!=nil){
                focused_component.input(focused_component, action, pressed)
            }
        }
        return
    }
    move_mode=.MOVE_NONE
}

user_action::enum{
    ACTION_NONE,
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
    "GRAVE" = .GRAVE,
    "UP" = .UP,
    "DOWN" = .DOWN,
    "LEFT" = .LEFT,
    "RIGHT" = .RIGHT,
    "ENTER" = .ENTER,
    "BACKSPACE" = .BACKSPACE,
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
    "0" = .ZERO,
    "1" = .ONE,
    "2" = .TWO,
    "3" = .THREE,
    "4" = .FOUR,
    "5" = .FIVE,
    "6" = .SIX,
    "7" = .SEVEN,
    "8" = .EIGHT,
    "9" = .NINE,
    "." = .PERIOD,
}

mouse_button_map := map[string]rl.MouseButton{
    "MOUSE_LEFT" = .LEFT,
    "MOUSE_RIGHT" = .RIGHT,
    "MOUSE_MIDDLE" = .MIDDLE,
    "MOUSE_SCROLL_DOWN" = .FORWARD,
    "MOUSE_SCROLL_UP" = .BACK,
}

mouse_button_keybinds := make(map[rl.MouseButton]user_action)
button_keybinds := make(map[rl.KeyboardKey]user_action)
key_pending: bool = false

bindKeyToAction := proc(key: string, action: user_action) {
    if key in key_map {
        k := key_map[key]
        button_keybinds[k] = action
        console.log("Bound key: [", key, "] to action: [", action, "]")
    } else if key in mouse_button_map {
        k := mouse_button_map[key]
        mouse_button_keybinds[k] = action
        console.log("Bound key: [", key, "] to action: [", action, "]")
    } else{
        console.log_error("Invalid key: [", key, "]")
    }
}

checkMouseButtons := proc() {
    for name, button in mouse_button_map {
        if rl.IsMouseButtonPressed(button) {
            handleInput(name, mouse_button_keybinds[button], true)
        } else if rl.IsMouseButtonReleased(button) {
            handleInput(name, mouse_button_keybinds[button], false)
        } else if rl.GetMouseWheelMove() > 0 {
            handleInput("MOUSE_SCROLL_UP", .ACTION_NONE, true)
        } else if rl.GetMouseWheelMove() < 0 {
            handleInput("MOUSE_SCROLL_DOWN", .ACTION_NONE, true)
        }
    }
}

checkKeyboard := proc() {
    for name, key in key_map {
        if rl.IsKeyDown(key) {
            handleInput(name, button_keybinds[key], true)
        } else if rl.IsKeyReleased(key) {
            handleInput(name, button_keybinds[key], false)
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
    clear(&mouse_button_keybinds)
    clear(&mouse_button_map)
}
