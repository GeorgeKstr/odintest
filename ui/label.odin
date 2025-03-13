package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

label_render::proc(self: ^component){
    rgb: rl.Color
    text, ok := self.args[carg.TEXT].(string)
    if !ok {
        return
    }
    centered, cok := self.args[carg.CENTERED].(bool)
    if !cok {
        centered = false
    }
    hover, hok := self.args[carg.HOVER_COLOR].(rl.Color)
    if hok && isPointInsideBox(mousepos, self.content_origin, self.content_size) {
        rgb = hover
    } else {
        if self.args[carg.BACKGROUND] != nil {
            rgb = self.args[carg.BACKGROUND].(rl.Color)
        } else {
            rgb = rl.RAYWHITE
        }
    }
    textsize := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(text), f32(defs.header_fontsize), 0)
    if centered {
        draw_text(sto.clone_to_cstring(text), ui_font, self.content_origin + rl.Vector2{(self.content_size.x - textsize.x) / 2, (self.content_size.y - textsize.y) / 2}, rgb, 1.0)
    } else {
        draw_text(sto.clone_to_cstring(text), ui_font, self.content_origin + rl.Vector2{0, (self.content_size.y - textsize.y) / 2}, rgb, 1.0)
    }
}

label_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if self.action != nil && rl.IsMouseButtonPressed(.LEFT) {
        self.action(self, nil)
    }
    return true
}

create_label::proc(name: string, text: string, origin: rl.Vector2, size: rl.Vector2) -> ^component{
    c := new(component)
    c.id = name
    c.origin = origin
    c.size = size
    c.render = label_render
    c.input = label_input
    c.args[carg.TEXT] = text
    return c
}

create_label_autowidth::proc(name: string, text: string, origin: rl.Vector2, size: rl.Vector2) -> ^component{
    c := new(component)
    c.id = name
    c.origin = origin
    c.size = size
    textsize := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(text), f32(defs.header_fontsize), 0)
    c.size.x = textsize.x
    c.render = label_render
    c.input = label_input
    c.args[carg.TEXT] = text
    return c
}