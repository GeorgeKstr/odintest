package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

checkbox_side :: 30

checkbox_render::proc(self: ^component){
    rgb: rl.Color
    if self.args[carg.BACKGROUND] != nil {
        rgb = self.args[carg.BACKGROUND].(rl.Color)
    } else {
        rgb = rl.RAYWHITE
    }
    checked:= self.args[carg.CHECKED].(bool)
    checkbox_size := rl.Vector2{checkbox_side, checkbox_side}
    box_origin := self.content_origin + (self.content_size - checkbox_size) / 2
    if checked {
        draw_texture("assets/ui/checkbox_checked.png", box_origin, checkbox_size, 1.0)
    } else {
        draw_texture("assets/ui/checkbox.png", box_origin, checkbox_size, 1.0)
    }
}

checkbox_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsMouseButtonPressed(.LEFT) {
        checked, _ := self.args[carg.CHECKED].(bool)
        self.args[carg.CHECKED] = !checked
        if self.action != nil {
            self.action(self, !checked)
        }
    }
    return true
}

create_checkbox::proc(name: string, text: string, origin: rl.Vector2, size: rl.Vector2) -> ^component{
    c := new(component)
    c.id = name
    c.origin = origin
    c.size = size
    c.render = checkbox_render
    c.input = checkbox_input
    c.args[carg.TEXT] = text
    c.args[carg.CHECKED] = false
    return c
}
