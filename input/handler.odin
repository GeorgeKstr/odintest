package input
import rl "vendor:raylib"
import "core:fmt"
import "../ui"

handleInput := proc(action: user_action, pressed: bool) {
    fmt.println("action: ", action, pressed)
    w := ui.windows_head
    if ui.cursor_enabled {
        if action == user_action.ACTION_FIRE {
            if(pressed){
                w:=ui.hover_window
                if(w==nil){
                    return
                }
                ui.makeHead(w)
                fmt.println("Clicked on window: ", w.name)
                if(ui.isPointInsideHeader(ui.mousepos, w)){
                    if ui.mousepos.x >= w.content_origin.x+w.content_size.x-ui.headersize {
                        ui.closeWindow(w)
                        ui.hover_window = nil
                        return
                    }
                    fmt.println("Clicked on header")
                    ui.move_mode=true
                    ui.move_offset=w.content_origin - ui.mousepos
                    ui.move_offset.y-=ui.headersize
                }
            }
            else{
                ui.move_mode=false
            }
        }
    }
    if(w!=nil){
        if !w.flags[ui.windowFlags.W_NOHEADER] {
            
        }
    }
}