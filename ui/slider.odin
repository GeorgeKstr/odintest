package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

slider_height :: 12
slider_knob_size :: 20

slider_render::proc(self: ^component){
    value := self.args[carg.VALUE].(f32)
    min := self.args[carg.MIN].(f32)
    max := self.args[carg.MAX].(f32)
    step := self.args[carg.STEP].(f32)
    slider_origin := self.content_origin + rl.Vector2{0, (self.content_size.y - slider_height) / 2}
    slider_size := rl.Vector2{self.content_size.x, slider_height}
    draw_texture("assets/ui/slider_back.png", slider_origin, slider_size, 1.0)
    draw_texture("assets/ui/slider_side_l.png", slider_origin, rl.Vector2{slider_knob_size / 2, slider_height}, 1.0)
    draw_texture("assets/ui/slider_side_r.png", slider_origin + rl.Vector2{self.content_size.x - slider_knob_size / 2, 0}, rl.Vector2{slider_knob_size / 2, slider_height}, 1.0)
    knob_x := self.content_origin.x + slider_knob_size / 2 + (value-min) * (self.content_size.x - slider_knob_size) / (max-min) - slider_knob_size / 2
    slider_knob_origin := rl.Vector2{knob_x, slider_origin.y + (slider_height - slider_knob_size) / 2}
    if self.args[carg.CHECKED] != nil && self.args[carg.CHECKED].(bool) {
        draw_rectangle(slider_origin, rl.Vector2{slider_knob_origin.x-slider_origin.x+slider_knob_size/2, slider_height}, rl.RAYWHITE, 0.5)
        self.args[carg.VALUE] = rl.Clamp(min + (max-min)*(mousepos.x - self.content_origin.x - slider_knob_size/2) / (self.content_size.x - slider_knob_size), min, max)
        self.args[carg.VALUE] = min + f32(int((self.args[carg.VALUE].(f32) - min) / step + 0.5)) * step
    }
    draw_texture("assets/ui/slider_front.png", slider_knob_origin, rl.Vector2{slider_knob_size, slider_knob_size}, 1.0)
}

slider_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsMouseButtonDown(.LEFT) {
        self.args[carg.CHECKED] = true
    } else if rl.IsMouseButtonReleased(.LEFT) {
        self.args[carg.CHECKED] = false
    }
    return false
}

create_slider::proc(id: string, value: f32, min: f32, max: f32, step: f32, pos: rl.Vector2, size: rl.Vector2) -> ^component{
    c:=new(component)
    c.id = id
    c.origin = pos
    c.size = size
    c.args[carg.VALUE] = value
    c.args[carg.MIN] = min
    c.args[carg.MAX] = max
    c.args[carg.STEP] = step
    c.input = slider_input
    c.render = slider_render
    return c
}

