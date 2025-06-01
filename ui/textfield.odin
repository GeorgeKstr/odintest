package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import "core:strings"

buttontime:f64 = 0
textfield_padding::6


textfield_render::proc(self: ^component){
    rgb: rl.Color
    if self.args[carg.BACKGROUND] != nil {
        rgb = self.args[carg.BACKGROUND].(rl.Color)
    } else {
        rgb = rl.RAYWHITE
    }
    text_size := rl.MeasureTextEx(ui_font, "a", f32(defs.header_fontsize), 0)
    bg_pos := self.content_origin + rl.Vector2{0, -textfield_padding + (self.content_size.y - text_size.y) / 2}
    bg_size := rl.Vector2{self.content_size.x, text_size.y+textfield_padding*2}
    if self == focused_component {
        draw_rectangle(bg_pos, bg_size, rl.Color{100, 149, 237, 255}, 1.0)
        fg_pos := bg_pos + rl.Vector2{2, 2}
        fg_size := rl.Vector2{bg_size.x - 4, bg_size.y - 4}
        draw_rectangle(fg_pos, fg_size, rgb, 1.0)
    } else {
        draw_rectangle(bg_pos, bg_size, rgb, 1.0)
    }
    
    text, ok := self.args[carg.TEXT].(string)
    if !ok {
        text = ""
    }
    builder := strings.builder_make(context.allocator)
    caret, cok := self.args[carg.CARET].(int)
    if !cok {
        caret = 0
    }
    textbefore, _ := strings.substring_to(text, caret)
    textafter := ""
    if caret < len(text) {
        textafter, _ = strings.substring_from(text, caret)
    }
    newtext := strings.to_string(builder)
    text = strings.concatenate([]string{textbefore, newtext, textafter}, context.temp_allocator)
    if self == focused_component {
        if u64(rl.GetTime() * 2) % 2 == 1 {
            strings.write_rune(&builder, 0x7c)
        } else {
            strings.write_rune(&builder, ' ')
        }
        newtext = strings.to_string(builder)
        text = strings.concatenate([]string{textbefore, newtext, textafter}, context.temp_allocator)
        delete(newtext)
    }
    txt := strings.clone_to_cstring(text, context.temp_allocator)
    text_width := rl.MeasureTextEx(ui_font, txt, f32(defs.header_fontsize), 0).x
    offset := f32(0.0)
    if text_width > self.content_size.x {
        offset = self.content_size.x - text_width - 8.0 // 8.0 is the padding (4.0 from each side)
    }
    draw_text(strings.clone_to_cstring(text, context.temp_allocator), ui_font, bg_pos + rl.Vector2{4 + offset, bg_size.y - text_size.y - textfield_padding}, rl.BLACK, 1.0)
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
        } else if(key >= 32 && key <= 126 || key >= 48 && key <= 57){
            builder := strings.builder_make()
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
                textbefore, _ = strings.substring_to(text, caret)
                textafter, _ = strings.substring_from(text, caret)
            }
            strings.write_rune(&builder, key)
            newtext := strings.to_string(builder)
            text = strings.concatenate([]string{textbefore, newtext, textafter})
            delete(textbefore)
            strings.builder_destroy(&builder)
            self.args[carg.CARET] = caret + 1
        } else if rl.IsKeyDown(.LEFT) {
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
        } else if rl.IsKeyDown(.RIGHT) {
            if buttontime > rl.GetTime() {
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
        } else if rl.IsKeyDown(.BACKSPACE) {
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
                textbefore, _ = strings.substring_to(text, caret-1)
                textafter = ""
            } else {
                textbefore, _ = strings.substring_to(text, caret-1)
                textafter, _ = strings.substring_from(text, caret)
            }
            text = strings.concatenate([]string{textbefore, textafter})
            delete(textbefore)
            self.args[carg.CARET] = caret - 1
        } else if rl.IsKeyDown(.ENTER) {
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