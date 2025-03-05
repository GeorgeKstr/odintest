package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"
import "core:strconv"

focused_component:^component

carg::enum{
    TEXT,
    CARET,
    BACKGROUND,
}

stack_mode::enum{
    VERTICAL,
    HORIZONTAL,
    GHOST,
    RELATIVE,
    RELATIVE_HORIZONTAL
}

component::struct{
    id: string,
    origin: rl.Vector2,
    size: rl.Vector2,
    margin: rl.Vector4,
    content_origin: rl.Vector2,
    content_size: rl.Vector2,
    value: defs.data_union,
    input: proc(self: ^component, action: user_action, pressed: bool) -> bool,
    render: proc(self: ^component),
    action: proc(self: ^component, arg: defs.data_union),
    previous: ^component,
    next: ^component,
    args: map[carg]defs.data_union,
    stack: stack_mode,
    reference: ^component,
}

add_component::proc(w: ^window, c: ^component){
    if w.components == nil {
        w.components = c
    } else {
        c2 := w.components
        for c2.next != nil {
            c2 = c2.next
        }
        c2.next = c
        c.previous = c2
    }
}
