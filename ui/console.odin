package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import sto "core:strings"
import "../console"

history: ^component = nil
console_window : ^window = nil
console_location := rl.Vector2{0, 0}
console_size := rl.Vector2{500, 500+headersize}

fill_textfield :: proc(self: ^component, arg: defs.data_union){
	if self.reference != nil {
		self.reference.args[carg.TEXT] = arg.(string)
	}
}

enter_command :: proc(self: ^component, arg: defs.data_union){
	if self.reference != nil {
        line, ok := arg.(string)
        if !ok {
            return
        }
		data := sto.split(line, " ")
		if len(data) >0 {
			if console.isCommand(data[0]) {
				console.executeCommand(line)
			} else {
                if len(data)>1 {
                    console.setCvar(data[0], data[1])
                } else {
                    console.log("Error: Command [", data[0], "] not found")
                }
			}
		}
		self.args[carg.TEXT] = ""
		self.args[carg.CARET] = 0
		
	}
}

console_text_input :: proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsKeyPressed(.UP) {
        if history == nil {
            return true
        }
        hmax, ok := history.args[carg.MAX].(int)
        if !ok {
            return true
        }
        step, cok := self.args[carg.STEP].(int)
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
        self.args[carg.STEP] = i
        self.args[carg.TEXT] = temp.text
    } else if rl.IsKeyPressed(.DOWN) {
        if history == nil {
            return true
        }
        hmax, ok := history.args[carg.MAX].(int)
        if !ok {
            return true
        }
        step, cok := self.args[carg.STEP].(int)
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
        self.args[carg.STEP] = i
        self.args[carg.TEXT] = temp.text
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
        fmt.println("console cannot be initialized")
        return
    }
    if console_window == nil {
        console_window = createWindow(console_location, console_size, "console")
        w:= console_window
        w.render = update_console
        textarea := create_textarea("textarea1", rl.Vector2{0, 0}, rl.Vector2{0.100, -55.100})
        textarea.entries=history.entries
        textarea.margin={5, 5, 5, 2.5}
        textarea.args[carg.BACKGROUND] = rl.Color{255, 255, 200, 255}
        textarea.action=fill_textfield
        textarea.args[carg.SCROLLAMOUNT] = 1.0
        add_component(w, textarea)
        textfield := create_textfield("textfield1", "", rl.Vector2{0, 0}, rl.Vector2{0.100, 40})
        textfield.input = console_text_input
        textfield.margin={5, 2.5, 5, 2.5}
        textfield.args[carg.STEP] = 0
        textfield.reference=textarea
        textfield.action=enter_command
        focused_component=textfield
        add_component(w, textfield)

        textarea.reference=textfield
    } else {
        if windows_head == console_window {
            closeWindow(console_window)
        } else {
            makeHead(console_window)
        }
    }
}