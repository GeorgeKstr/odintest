package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"

buttontime:f64 = 0

textfield_render::proc(self: ^component){
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
    builder := sto.builder_make()
    caret, cok := self.args[carg.CARET].(int)
    if !cok {
        caret = 0
    }
    textbefore, _ := sto.substring_to(text, caret)
    textafter := ""
    if caret < len(text) {
        textafter, _ = sto.substring_from(text, caret)
    }
    newtext := sto.to_string(builder)
    text = sto.concatenate([]string{textbefore, newtext, textafter})

    text_width := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(text), f32(defs.header_fontsize), 0).x
    offset := f32(0.0)
    if text_width > self.content_size.x {
        offset = self.content_size.x - text_width - 8.0 // 8.0 is the padding (4.0 from each side)
    }
    if self == focused_component {
        if u64(rl.GetTime() * 2) % 2 == 1 {
            sto.write_rune(&builder, 0x7c)
        } else {
            sto.write_rune(&builder, ' ')
        }
        newtext = sto.to_string(builder)
        text = sto.concatenate([]string{textbefore, newtext, textafter})
    }
    draw_text(sto.clone_to_cstring(text), ui_font, self.content_origin + rl.Vector2{4 + offset, 4}, rl.BLACK, 1.0)
}

textfield_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    
    if pressed {
        key := rl.GetCharPressed()
        text, ok := self.args[carg.TEXT].(string)
        if !ok {
            text = ""
        }
        if rl.IsMouseButtonPressed(.LEFT) {
            self.args[carg.CARET] = len(text)
        }
        else if(key >= 32 && key <= 126 || key >= 48 && key <= 57){
            builder := sto.builder_make()
            caret, ok := self.args[carg.CARET].(int)
            if !ok {
                caret = 0
            }
            textbefore, textafter := "", ""
            if caret == 0 {
                textbefore = ""
                textafter = text
            } else if caret == len(text) {
                textbefore = text
                textafter = ""
            } else {
                textbefore, _ = sto.substring_to(text, caret)
                textafter, _ = sto.substring_from(text, caret)
            }
            sto.write_rune(&builder, key)
            newtext := sto.to_string(builder)
            text = sto.concatenate([]string{textbefore, newtext, textafter})
            self.args[carg.CARET] = caret + 1
        }
        else if rl.IsKeyDown(.LEFT) {
            if(buttontime > rl.GetTime()){
                return true
            }
            buttontime = rl.GetTime() + 0.1
            caret, ok := self.args[carg.CARET].(int)
            if !ok {
                caret = 0
            }
            caret -= 1
            if caret < 0 {
                caret = 0
            }
            self.args[carg.CARET] = caret
        }
        else if rl.IsKeyDown(.RIGHT) {
            if(buttontime > rl.GetTime()){
                return true
            }
            buttontime = rl.GetTime() + 0.1
            caret, ok := self.args[carg.CARET].(int)
            if !ok {
                caret = 0
            }
            caret += 1
            text, cok := self.args[carg.TEXT].(string)
            if !cok {
                text = ""
            }
            if caret > len(text) {
                caret = len(text)
            }
            self.args[carg.CARET] = caret
        }
        else if rl.IsKeyDown(.BACKSPACE) {
            if(buttontime > rl.GetTime()){
                return true
            }
            buttontime = rl.GetTime() + 0.05
            caret, ok := self.args[carg.CARET].(int)
            if !ok {
                caret = 0
            }
            textbefore, textafter := "", ""
            if caret == 0 {
                return true
            } else if caret == len(text) {
                textbefore, _ = sto.substring_to(text, caret-1)
                textafter = ""
            } else {
                textbefore, _ = sto.substring_to(text, caret-1)
                textafter, _ = sto.substring_from(text, caret)
            }
            text = sto.concatenate([]string{textbefore, textafter})
            self.args[carg.CARET] = caret - 1
        }
        else if rl.IsKeyDown(.ENTER) {
            text, ok := self.args[carg.TEXT].(string)
            if !ok || len(text) == 0 {
                return true
            }
            if self.action != nil {
                self.action(self, text)
                return true
            }
        }

        self.args[carg.TEXT] = text
    }
    return true
}

create_textfield::proc(id: string, text: string, pos: rl.Vector2, size: rl.Vector2) -> ^component{
    c:=new(component)
    c.id = id
    c.origin = pos
    c.size = size
    c.args[carg.TEXT] = text
    c.args[carg.CARET] = 0
    c.input = textfield_input
    c.render = textfield_render
    return c
}