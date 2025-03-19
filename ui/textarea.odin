package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"
import "core:strings"

text_offset::4

calculate_lines::proc(self : ^component) -> f32{
    line:=self.entries
    space_width := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(" "), f32(defs.header_fontsize), 0).x
    y:=0
    for line != nil {
        line.size.x = self.content_size.x
        words := strings.split(line.text, " ")
        line_to_print:=""
        start_y:=y
        if len(words) > 1 {
            x := f32(0)
            for word, i in words {
                cword := sto.clone_to_cstring(word)
                word_width := rl.MeasureTextEx(ui_font, cword, f32(defs.header_fontsize), 0).x
                if i>=len(words)-1 {
                    x=text_offset
                } else if text_offset+x+word_width > self.content_size.x {
                    x=word_width
                    y+=1 
                } else {
                    x+=word_width + space_width
                }  
            }
        }
        y+=1
        line.size.y=f32((y-start_y)*defs.header_fontsize)
        line=line.next
    }
    return f32(y)
}

textarea_render::proc(self: ^component){
    space_width := rl.MeasureTextEx(ui_font, sto.clone_to_cstring(" "), f32(defs.header_fontsize), 0).x
    rgb: rl.Color
    if self.args[carg.BACKGROUND] != nil {
        rgb = self.args[carg.BACKGROUND].(rl.Color)
    } else {
        rgb = rl.RAYWHITE
    }
    if(self == focused_component){
        draw_rectangle(self.content_origin, self.content_size, rl.Color{100, 149, 237, 255}, 1.0)
        draw_rectangle(self.content_origin + rl.Vector2{text_offset/2, text_offset/2}, self.content_size - rl.Vector2{text_offset, text_offset}, rgb, 1.0)
    } else {
        draw_rectangle(self.content_origin, self.content_size, rgb, 1.0)
    }
    total_lines := calculate_lines(self)
    total_height := total_lines * defs.header_fontsize+text_offset*2
    scroll_offset := f32(0)
    if total_height > self.content_size.y {
        self.args[carg.SCROLL] = true
        draw_rectangle(self.content_origin + rl.Vector2{self.content_size.x-scrollsize, 0}, rl.Vector2{scrollsize, self.content_size.y}, rl.BLACK, 0.5)
        scrollBarSize := rl.Vector2{scrollsize, self.content_size.y * (self.content_size.y / total_height)}
        scroll_amount, ok := self.args[carg.SCROLLAMOUNT].(f32)
        if !ok {
            scroll_amount = f32(0)
        }
        scrollBarPos := rl.Vector2{self.content_origin.x + self.content_size.x - scrollsize, self.content_origin.y + (self.content_size.y - scrollBarSize.y) * scroll_amount}
        draw_rectangle(scrollBarPos, scrollBarSize, rl.Color{180, 180, 180, 255}, 1.0)
        self.content_size.x -= scrollsize
        if move_mode==.MOVE_COMPONENT {
            scrollamount := rl.Clamp((mousepos.y - self.content_origin.y-scrollBarSize.y/2) / (self.content_size.y-scrollBarSize.y), f32(0), f32(1))
            self.args[carg.SCROLLAMOUNT] = scrollamount
        }
        scroll_offset = (total_height - self.content_size.y) * scroll_amount
    } else {
        self.args[carg.SCROLL] = false
    }
    total_offset:= scroll_offset-text_offset
    line:=self.entries
    y:=0
    for line!=nil {
        words := strings.split(line.text, " ")
        line_to_print:=""
        line.origin = self.content_origin + rl.Vector2{0, f32(y*defs.header_fontsize)-total_offset}
        if line.rgb != nil{
            draw_rectangle(line.origin, rl.Vector2{self.content_size.x, line.size.y}, line.rgb^, 0.3)
        }
        if len(words) == 1 {
            draw_text(sto.clone_to_cstring(line.text), ui_font, self.content_origin + rl.Vector2{text_offset, f32(y*defs.header_fontsize)-total_offset}, rl.BLACK, 1.0)
        } else {
            x := f32(0)
            for word, i in words {
                cword := sto.clone_to_cstring(word)
                word_width := rl.MeasureTextEx(ui_font, cword, f32(defs.header_fontsize), 0).x
                if text_offset+x+word_width > self.content_size.x {
                    draw_text(sto.clone_to_cstring(line_to_print), ui_font, self.content_origin + rl.Vector2{text_offset, f32(y*defs.header_fontsize)-total_offset}, rl.BLACK, 1.0)
                    line_to_print = word
                    x=word_width
                    y+=1 
                } else if i>=len(words)-1 {
                    line_to_print = sto.concatenate([]string{line_to_print, " ", word})
                    draw_text(sto.clone_to_cstring(line_to_print), ui_font, self.content_origin + rl.Vector2{text_offset, f32(y*defs.header_fontsize)-total_offset}, rl.BLACK, 1.0)
                    x=text_offset
                } else {
                    if i<1{
                        line_to_print = word
                    } else {
                        line_to_print = sto.concatenate([]string{line_to_print, " ", word})
                    }
                    x+=word_width + space_width
                } 
            }
        }
        line=line.next
        y+=1
    }
    if total_height > self.content_size.y {
        self.content_size.x+=scrollsize
    }
}

textarea_input::proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsMouseButtonDown(.LEFT) {
        if isPointInsideBox(mousepos, self.content_origin+rl.Vector2{self.content_size.x-scrollsize, 0}, rl.Vector2{scrollsize, self.content_size.y}) {
            move_mode=.MOVE_COMPONENT
        } 
        return true
    } else if rl.IsMouseButtonDown(.RIGHT) {
        line := self.entries
        for line != nil {
            if isPointInsideBox(mousepos, line.origin, line.size) {
                if self.action!=nil {
                    self.action(self, line.text)
                }
                return true
            }
            line = line.next
        }
    } else if isPointInsideBox(mousepos, self.content_origin, self.content_size) && rl.GetMouseWheelMove() != 0 && self.args[carg.SCROLL] != nil && self.args[carg.SCROLL].(bool){
        scroll, ok := self.args[carg.SCROLLAMOUNT].(f32)
        if !ok {
            scroll = f32(0)
        }
        scroll = rl.Clamp(scroll - rl.GetMouseWheelMove()*0.01, f32(0), f32(1))
        self.args[carg.SCROLLAMOUNT] = scroll
    }
    return true
}

create_textarea::proc(id: string, pos: rl.Vector2, size: rl.Vector2) -> ^component{
    c:=new(component)
    c.id = id
    c.origin = pos
    c.size = size
    c.entries = nil
    c.args[carg.CARET] = 0
    c.input = textarea_input
    c.render = textarea_render
    return c
}

add_entry::proc(self: ^component, text: string, color: rl.Color){
    entry:=new(entry)
    entry.text = text
    color2 := new (rl.Color)
    color2.r = color.r
    color2.g = color.g
    color2.b = color.b
    color2.a = 255
    entry.rgb = color2
    entry.next = nil

    maxentries, ok := self.args[carg.MAX].(int)
    if !ok {
        maxentries = 1
    }
    oldtext := self.entries
    if oldtext == nil {
        self.entries = entry
    } else {
        i:=1
        temp := oldtext
        for temp.next != nil {
            temp = temp.next
            i+=1
        }
        temp.next = entry
        if i>=maxentries {
            temp = self.entries
            for i>=maxentries {
                nxt := temp.next
                free(temp)
                temp = nxt
                i-=1
            }
            self.entries = temp
        }
    }
}
