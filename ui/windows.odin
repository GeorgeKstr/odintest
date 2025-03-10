package ui

import rl "vendor:raylib"
import "../defs"
import "core:fmt"
import "core:strconv"
ui_font : rl.Font
windows_head: ^window = nil
windows_tail: ^window = nil
hover_window: ^window = nil
mousepos: rl.Vector2
cursor_enabled: bool=true
wlasty: f32
walpha: f32
scrolloffset: f32
move_offset: rl.Vector2
move_mode: moveMode = .MOVE_NONE
screensize: rl.Vector2
ratio: f32
headersize:= f32(defs.header_height)
scrollsize :: 12
edgesize :: 8
closesize :: 0.6
windows_color :: rl.Color{25, 25, 25, 150}
scrollbar_background :: rl.Color{50, 50, 50, 255}
scrollbar_color :: rl.Color{100, 100, 100, 255}

moveMode :: enum {
    MOVE_NONE,
    MOVE_RESIZE_LEFT,
    MOVE_RESIZE_RIGHT,
    MOVE_MOVE
}

windowFlags :: enum {
    W_NONE,
    W_NOMOVE,
    W_NORESIZE,
    W_NOHEADER,
    W_RELATIVETOSCREEN,
    W_NOHEAD,
    W_NOSCROLLBAR,
    W_BLOCKINPUT
}

stackFlags :: enum {
    STACK_BLOCK,
    STACK_INLINE,
    STACK_GHOST,
    STACK_ABSOLUTE
}

alignFlags :: enum {
    ALIGN_LEFT,
    ALIGN_CENTER,
    ALIGN_RIGHT
}

animationFlags :: enum {
    ANIMATION_NONE,
    ANIMATION_FADEIN,
    ANIMATION_FADEOUT
}

window :: struct {
    origin: rl.Vector2,
    size: rl.Vector2,
    name: cstring,
    flags: [len(windowFlags)]bool,
    scrollable: bool,
    scroll: f32,
    content_origin: rl.Vector2,
    content_size: rl.Vector2,
    components: ^component,
    next: ^window,
    previous: ^window,
    draw: proc(),
    input: proc(self: ^window, user_action: user_action, pressed: bool) -> bool,
    args: map[string]defs.data_union
}

entity :: struct {
    origin: rl.Vector2,
    size: rl.Vector2,
    flags: [len(stackFlags)]bool,
    text: cstring,
    draw: proc(),
    input: proc() -> bool,
    next: ^entity,
    previous: ^entity,
    container: ^window,
    handles_input: bool,
    is_active: bool
}

setScreenValues :: proc(vwidth: f32, vheight: f32) {
    screensize = rl.Vector2{vwidth, vheight}
    ratio = screensize.x / screensize.y
    mousepos = rl.Vector2{f32(rl.GetMousePosition().x), f32(rl.GetMousePosition().y)}
}

isPointInsideBox :: proc(pos: rl.Vector2, origin: rl.Vector2, size: rl.Vector2) -> bool {
    return (pos.x >= origin.x && pos.x <= origin.x + size.x && pos.y >= origin.y && pos.y <= origin.y + size.y)
}

isPointInsideHeader :: proc(pos: rl.Vector2, w: ^window) -> bool {
    if(w.flags[windowFlags.W_NOHEADER] || w.flags[windowFlags.W_NORESIZE] || w.flags[windowFlags.W_RELATIVETOSCREEN]) {
        return false        
    }
    else{
        if(isPointInsideBox(pos, w.origin, rl.Vector2{w.size.x, headersize})){
            return true
        }
    }
    return false
}

drawHeader :: proc(w: ^window) {
    draw_texture("assets/ui/win_header.png", w.content_origin, rl.Vector2{w.content_size.x, headersize}, walpha)
    draw_text_centered(w.name, ui_font, w.content_origin, {w.content_size.x, headersize}, rl.RAYWHITE, walpha)
    draw_texture_centered("assets/ui/win_close.png", rl.Vector2{w.content_origin.x + w.content_size.x - headersize/2, w.content_origin.y+headersize/2}, rl.Vector2{headersize, headersize}*closesize, walpha*0.7)

    w.content_origin.y += headersize
    w.content_size.y -= headersize
}

drawBody :: proc(w: ^window) {
    draw_rectangle(w.content_origin, w.content_size, windows_color, walpha)
}

drawScrollbar :: proc(w: ^window) {
    barpos := rl.Vector2{w.content_origin.x + w.content_size.x - scrollsize, w.content_origin.y}
    barsize := rl.Vector2{scrollsize, w.content_size.y * w.scroll}
    draw_rectangle(barpos, barsize, scrollbar_color, 1.0)
}

createWindow :: proc(pos: rl.Vector2, size: rl.Vector2, name: cstring) -> ^window {
    w := new(window)
    w.origin = pos
    w.size = size
    w.name = name
    if windows_head == nil {
        windows_head = w
        windows_tail = w
    } else {
        windows_tail.next = w
        w.previous = windows_tail
        windows_tail = w
    }
    return w
}

closeWindow :: proc(w: ^window) {
    if windows_head == w {
        windows_head = w.next
    }
    if w.next != nil {
        w.next.previous = w.previous
    }
    if w.previous != nil {
        w.previous.next = w.next
    }
    free(w)
}

makeHead :: proc(w: ^window) {
    if w==nil {
        return
    }
    if windows_head == w {
        return
    }
    if w.previous != nil {
        w.previous.next = w.next
    }
    if w.next != nil {
        w.next.previous = w.previous
    }
    w.next = windows_head
    if(windows_head != nil){
        windows_head.previous = w
    }
    w.previous = nil
    windows_head = w
    w2 := w
    for w2.next != nil {
        w2 = w2.next
    }
    windows_tail = w2
}

calculateScroll :: proc(w: ^window) -> f32 {
    content_start:=rl.Vector2{w.content_origin.x, 0}
    for c := w.components; c != nil; c = c.next {
        c.content_origin = content_start
        if(c.stack==.GHOST && c.previous!=nil){
            c.content_origin.y = c.previous.content_origin.y
        }
        corigin := rl.Vector2{f32(int(c.origin.x)), f32(int(c.origin.y))}
        csize := rl.Vector2{f32(int(c.size.x)), f32(int(c.size.y))}
        relative_origin := rl.Vector2{c.origin.x - corigin.x, c.origin.y - corigin.y}*1000
        relative_size := rl.Vector2{c.size.x - csize.x, c.size.y - csize.y}*1000
        c.content_size.x = csize.x + w.content_size.x*relative_size.x/100
        c.content_size.y = csize.y + w.content_size.y*relative_size.y/100
        c.content_origin.y += corigin.y + (w.content_size.y-c.content_size.y)*relative_origin.y/100
        c.content_origin.x += corigin.x + (w.content_size.x-c.content_size.x)*relative_origin.x/100
        c.content_origin.x += c.margin.x
        c.content_origin.y += c.margin.y
        c.content_size.x -= c.margin.z+c.margin.x
        c.content_size.y -= c.margin.w+c.margin.y
        if c.stack != .GHOST && c.stack != .HORIZONTAL {
            content_start.y += c.content_size.y+c.margin.w+c.margin.y
        }
    }
    return content_start.y/w.content_size.y
}

drawWindows :: proc() {
    if windows_head == nil {
        return
    }
    setScreenValues(f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight()))
    hover_window=nil
    w := windows_head
    if move_mode == .MOVE_MOVE {
        w.origin = mousepos + move_offset
    } else if move_mode == .MOVE_RESIZE_RIGHT {
        w.size = - w.origin + mousepos - move_offset
    } else if move_mode == .MOVE_RESIZE_LEFT {
        neworigin:= mousepos.x - move_offset.x
        w.size.x += w.origin.x - neworigin
        w.origin.x = neworigin
        w.size.y = - w.origin.y + mousepos.y - move_offset.y
    }
    w = windows_tail
    for w != nil {
        walpha = w.previous == nil ? 1.0 : 0.5
        if w.flags[windowFlags.W_RELATIVETOSCREEN] {
            w.content_size.x = screensize.x*0.01 * w.size.x
            w.content_size.y = headersize + screensize.y*0.01 * w.size.y
            w.content_origin.x = (screensize.x - w.content_size.x)*0.01*w.origin.x
            w.content_origin.y = (screensize.y - w.content_size.y)*0.01 * w.origin.y
        } else {
            if w.origin.x < 0 {
                w.origin.x = 0
            } else if w.origin.x + w.size.x > screensize.x {
                w.origin.x = screensize.x - w.size.x
            }
            if w.origin.y < 0 {
                w.origin.y = 0
            } else if w.origin.y + w.size.y > screensize.y {
                w.origin.y = screensize.y - w.size.y
            }
            w.content_origin = w.origin
            w.content_size = w.size
        }

        if isPointInsideBox(mousepos, w.content_origin, w.content_size) {
            hover_window = w
        }
        
        if !w.flags[windowFlags.W_NOHEADER] {
            drawHeader(w)
        }
        drawBody(w)
        scrollAmount := calculateScroll(w)
        previousX := w.content_size.x
        if(scrollAmount > 1.0){
            draw_rectangle(rl.Vector2{w.content_origin.x+w.content_size.x-scrollsize, w.content_origin.y}, rl.Vector2{scrollsize, w.content_size.y}, scrollbar_background, 1.0*walpha)
            scrollbarSize := rl.Vector2{scrollsize - 2, w.content_size.y / scrollAmount - 2}
            scrollbarPos := rl.Vector2{
                w.content_origin.x + w.content_size.x - scrollsize + 1,
                w.content_origin.y + 1+(w.content_size.y - scrollbarSize.y - 1) * w.scroll
            }
            draw_rectangle(scrollbarPos, scrollbarSize, scrollbar_color, 1.0 * walpha)
            w.content_size.x -= scrollsize
            w.scrollable = true
        } else {
            w.scrollable = false
            w.scroll=0.0
        }
        content_start:=rl.Vector2{w.content_origin.x, w.content_origin.y}
        content_start.y -= w.content_size.y*(scrollAmount-1.0)*w.scroll
        for c := w.components; c != nil; c = c.next {
            c.content_origin = content_start
            if(c.stack==.GHOST && c.previous!=nil){
                c.content_origin.y = c.previous.content_origin.y
            }
            corigin := rl.Vector2{f32(int(c.origin.x)), f32(int(c.origin.y))}
            csize := rl.Vector2{f32(int(c.size.x)), f32(int(c.size.y))}
            relative_origin := rl.Vector2{abs(c.origin.x - corigin.x), abs(c.origin.y - corigin.y)}*1000
            relative_size := rl.Vector2{abs(c.size.x - csize.x), abs(c.size.y - csize.y)}*1000
            c.content_size.x = csize.x + w.content_size.x*relative_size.x/100
            c.content_size.y = csize.y + w.content_size.y*relative_size.y/100
            c.content_origin.y += corigin.y + (w.content_size.y-c.content_size.y)*relative_origin.y/100
            c.content_origin.x += corigin.x + (w.content_size.x-c.content_size.x)*relative_origin.x/100
            c.content_origin.x += c.margin.x
            c.content_origin.y += c.margin.y
            c.content_size.x -= c.margin.z+c.margin.x
            c.content_size.y -= c.margin.w+c.margin.y
            if(c.content_origin.y<w.content_origin.y+w.content_size.y){
                rl.BeginScissorMode(i32(c.content_origin.x), i32(max(c.content_origin.y, w.content_origin.y)), i32(c.content_size.x), i32(min(c.content_origin.y+c.content_size.y, w.content_origin.y+w.content_size.y)-max(c.content_origin.y, w.content_origin.y)))
                c.render(c)
                rl.EndScissorMode()
            }
            if c.stack != .GHOST && c.stack != .HORIZONTAL {
                content_start.y += c.content_size.y+c.margin.w+c.margin.y
            }
        }
        w.content_size.x = previousX
        if !(w.flags[windowFlags.W_NORESIZE]) {
            draw_texture_centered("assets/ui/win_scale_l.png", rl.Vector2{w.content_origin.x, w.content_origin.y + w.content_size.y}, rl.Vector2{headersize, headersize}, walpha)
            draw_texture_centered("assets/ui/win_scale_r.png", rl.Vector2{w.content_origin.x + w.content_size.x, w.content_origin.y + w.content_size.y}, rl.Vector2{headersize, headersize}, walpha)
        }
        w = w.previous
    }
}


