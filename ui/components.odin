package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"
import "core:strconv"

focused_component:^component

component::struct{
    container: ^window,
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
    args: map[carg]defs.data_union,
    stack: stack_mode,
    previous: ^component,
    reference: ^component,
    entries: [dynamic] ^entry,
}

carg::enum{
    TEXT,
    CARET,
    BACKGROUND,
    VALUE,
    MIN,
    MAX,
    STEP,
    HOVER_COLOR,
    CHECKED,
    CENTERED,
    SCROLL,
    SCROLLAMOUNT,
}

stack_mode::enum{
    VERTICAL,
    HORIZONTAL,
    GHOST,
    RELATIVE,
    RELATIVE_HORIZONTAL,
}

entry::struct {
    text: string,
    origin: rl.Vector2,
    size: rl.Vector2,
    rgb: ^rl.Color,
}

add_component::proc(w: ^window, c: ^component){
    append(&w.components, c)
}

remove_component_from_window::proc(w: ^window, c: ^component){
    for c2, i in w.components {
        if c2 == c {
            ordered_remove(&w.components, i)
            remove_component(c)
            return
        }
    }
}

remove_component::proc(c: ^component) {
    fmt.println("ENTRIES TO REMOVE: ", c.entries)
    for &e in c.entries {
        fmt.println("deleting entry: ", e)
        free(e.rgb)
        delete(e.text)
        free(e)
    }
    delete(c.entries)
    for k, &v in c.args {
        fmt.println("deleting arg: ", v)
        defs.data_union_delete(&v)
    }
    delete(c.args)
    free(c)
}


