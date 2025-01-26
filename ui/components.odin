package ui

import rl "vendor:raylib"
import "core:fmt"

component::struct{
    id: string,
    pos: rl.Vector2,
    size: rl.Vector2,
    input: proc(self: ^component),
    render: proc(self: ^component),
    previous: ^component,
    next: ^component,
}



textfield_render::proc(self: ^component){
    rl.DrawRectangle(i32(self.pos.x), i32(self.pos.y), i32(self.size.x), i32(self.size.y), rl.RAYWHITE);
}

textfield_input::proc(self: ^component){
    if rl.IsKeyPressed(.BACKSLASH) {
        fmt.println("backslash pressed");
    } else if rl.IsKeyPressed(.ENTER) {
        fmt.println("changing line");
    } else if rl.IsKeyPressed(.ESCAPE) {
        fmt.println("escape");
    } else {
        fmt.println(rl.GetKeyPressed())
    }
}

textfield::proc(id: string, pos: rl.Vector2, size: rl.Vector2)->component{
    result:component;
    result.id, result.pos, result.size = id, pos, size;
    result.render=textfield_render;
    result.input=textfield_input;
    return result;
}

