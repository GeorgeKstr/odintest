package ui

import rl "vendor:raylib"
import "../ui"
import "core:fmt"
import "../defs"
import sto "core:strings"

history: ^component = nil
console_window : ^window = nil
console_location := rl.Vector2{0, 0}
console_size := rl.Vector2{500, 500+ui.headersize}

console_log :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    ui.add_entry(history, fmt.aprint(..args), rl.Color{0,0,0,0})
}

console_error :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    ui.add_entry(history, fmt.aprint(..args), rl.RED)
}

console_warn :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    ui.add_entry(history, fmt.aprint(..args), rl.YELLOW)
}

fill_textfield :: proc(self: ^ui.component, arg: defs.data_union){
	if self.reference != nil {
		self.reference.args[ui.carg.TEXT] = arg.(string)
	}
}

enter_command :: proc(self: ^ui.component, arg: defs.data_union){
	if self.reference != nil {
		//ui.add_entry(self.reference, arg.(string), rl.RED)
		self.args[ui.carg.TEXT] = ""
		self.args[ui.carg.CARET] = 0
		
	}
}

console_text_input :: proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsKeyPressed(.UP) {
        if history == nil {
            return true
        }
        hmax, ok := history.args[ui.carg.MAX].(int)
        if !ok {
            return true
        }
        step, cok := self.args[ui.carg.STEP].(int)
        if !cok {
            step=0
        }
        step -=1
        if step < 0 {
            step=hmax
        }
        temp:=history.entries
        i:=0
        for i<step && temp.next != nil {
            temp=temp.next
            i+=1
        }
        self.args[ui.carg.STEP] = i
        self.args[ui.carg.TEXT] = temp.text
    } else if rl.IsKeyPressed(.DOWN) {
        if history == nil {
            return true
        }
        hmax, ok := history.args[ui.carg.MAX].(int)
        if !ok {
            return true
        }
        step, cok := self.args[ui.carg.STEP].(int)
        if !cok {
            step=0
        }
        step +=1
        temp:=history.entries
        i:=0
        for i<step {
            if temp.next == nil {
                temp=history.entries
                i=0
                break
            }
            temp=temp.next
            i+=1
        }
        self.args[ui.carg.STEP] = i
        self.args[ui.carg.TEXT] = temp.text
    } else {
        textfield_input(self, action, pressed)
    }
    return true
}

update_console :: proc(self: ^window){
    console_location=self.origin
    console_size=self.size    
}


create_console :: proc(){
    if history == nil {
        fmt.println("console canot be initialized")
        return
    }
    if console_window == nil {
        console_window = createWindow(console_location, console_size, "console")
        w:= console_window
        w.render = update_console
        textarea := ui.create_textarea("textarea1", rl.Vector2{0, 0}, rl.Vector2{0.100, -55.100})
        textarea.entries=history.entries
        textarea.margin={5, 5, 5, 2.5}
        textarea.args[ui.carg.BACKGROUND] = rl.Color{255, 255, 200, 255}
        textarea.action=fill_textfield
        textarea.args[ui.carg.SCROLLAMOUNT] = 1.0
        ui.add_component(w, textarea)
        textfield := ui.create_textfield("textfield1", "", rl.Vector2{0, 0}, rl.Vector2{0.100, 40})
        textfield.input = console_text_input
        textfield.margin={5, 2.5, 5, 2.5}
        textfield.args[ui.carg.STEP] = 0
        textfield.reference=textarea
        textfield.action=enter_command
        focused_component=textfield
        ui.add_component(w, textfield)

        textarea.reference=textfield
    } else {
        if windows_head == console_window {
            closeWindow(console_window)
        } else {
            makeHead(console_window)
        }
    }
}