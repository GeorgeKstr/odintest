package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

textarea_render::proc(self: ^component){
    rgb: rl.Color
    if self.args[carg.BACKGROUND] != nil {
        rgb = self.args[carg.BACKGROUND].(rl.Color)
    } else {
        rgb = rl.RAYWHITE
    }
    if(self == focused_component){
        draw_rectangle(self.content_origin, self.content_size, rl.Color{100, 149, 237, 255}, 1.0)
        draw_rectangle(self.content_origin + rl.Vector2{2, 2}, self.content_size - rl.Vector2{4, 4}, rgb, 1.0)
    } else {
        draw_rectangle(self.content_origin, self.content_size, rgb, 1.0)
    }
    text, ok := self.args[carg.TEXT].(string)
    if !ok {
        text = ""
    }
    lines := sto.split(text, "\n")
    for line, i in lines {
        draw_text(sto.clone_to_cstring(line), ui_font, self.content_origin + rl.Vector2{4, f32(i * (defs.header_fontsize + 4)) + 4}, rl.BLACK, 1.0)
    }
}

textarea_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    
    return true
}

textarea_action::proc(self: ^component, arg: defs.data_union){
    newtext, ok := arg.(string)
    if ok {
        oldtext, _ := self.args[carg.TEXT].(string)
        self.args[carg.TEXT] = sto.concatenate([]string{oldtext, "\n", newtext})
    }
}

create_textarea::proc(id: string, text: string, pos: rl.Vector2, size: rl.Vector2) -> ^component{
    c:=new(component)
    c.id = id
    c.origin = pos
    c.size = size
    c.args[carg.TEXT] = text
    c.args[carg.CARET] = 0
    c.input = textarea_input
    c.render = textarea_render
    c.action=textarea_action
    return c
}
