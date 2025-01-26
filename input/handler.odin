package input
import rl "vendor:raylib"


setMousePosition := proc(x: f32, y: f32) {
    rl.SetMousePosition(x, y)
}

mousepos_label: rl.Vector2

handleInput := proc() {
    w := ui.windows_head
    mousepos := rl.GetMousePosition()
    mousepos_label = rl.Vector2{mousepos.x, mousepos.y}
    if(w!=nil){
        if !w.flags[windowFlags.W_NOHEADER] {
            
        }
    }
}