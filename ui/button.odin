package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

button_height :: 30

button_render::proc(self: ^component){
    rgb: rl.Color
    if self.args[carg.BACKGROUND] != nil {
        rgb = self.args[carg.BACKGROUND].(rl.Color)
    } else {
        rgb = rl.RAYWHITE
    }
    draw_texture("assets/ui/button.png", self.content_origin + rl.Vector2{0, (self.content_size.y - button_height) / 2}, rl.Vector2{self.content_size.x, button_height}, 1.0)
    text, ok := self.args[carg.TEXT].(string)
    if !ok {
        text = ""
    }
    textsize := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(text), f32(defs.header_fontsize), 0)
    draw_text(sto.clone_to_cstring(text), ui_font, self.content_origin + rl.Vector2{(self.content_size.x - textsize.x) / 2, (self.content_size.y - textsize.y) / 2}, rl.RAYWHITE, 1.0)
}

button_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsMouseButtonPressed(.LEFT) {
        if self.action != nil {
            self.action(self, nil)
        }
    }
    return true
}

create_button::proc(name: string, text: string, origin: rl.Vector2, size: rl.Vector2) -> ^component{
    c := new(component)
    c.id = name
    c.origin = origin
    c.size = size
    c.render = button_render
    c.input = button_input
    c.args[carg.TEXT] = text
    return c
}