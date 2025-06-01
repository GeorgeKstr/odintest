package ui

import rl "vendor:raylib"
import "core:fmt"
import "../defs"
import "core:strings"
import "../console"

history: ^component = nil
command_history: ^component = nil
console_window : ^window = nil
console_location := rl.Vector2{0, 0}
console_size := rl.Vector2{500, 500+headersize}


ui_enter_command :: proc(self: ^component, arg: defs.data_union){
    if self.reference != nil {
        line, ok := arg.(string)
        if !ok {
            return
        }
		data := strings.split(line, " ", context.temp_allocator)
		if len(data) >0 {
            console.log_cmd(line)
            add_entry(command_history, line, rl.Color{0,0,0,0})
			console.executeCommand(line)
		}
		self.args[carg.TEXT] = ""
		self.args[carg.CARET] = 0
        
	}
}

fill_textfield :: proc(self: ^component, arg: defs.data_union){
    if self.reference != nil {
        self.reference.args[carg.TEXT] = arg.(string)
    }
}

ui_console_text_input :: proc(self: ^component, action: user_action, pressed: bool) -> bool{
    if rl.IsKeyPressed(.UP) {
        if command_history == nil {
            return true
        }
        if len(command_history.entries) == 0 {
            return true
        }
        index, ok := self.args[carg.STEP].(int)
        if !ok {
            index = 0
        }
        index -= 1
        if index < 0 {
            index = len(command_history.entries) - 1
        }
        text := command_history.entries[index].text
        fmt.println(text)
        self.args[carg.TEXT] = text
        self.args[carg.STEP] = index
        self.args[carg.CARET] = len(text)
    } else if rl.IsKeyPressed(.DOWN) {
        if command_history == nil {
            return true
        }
        if len(command_history.entries) == 0 {
            return true
        }
        index, ok := self.args[carg.STEP].(int)
        if !ok {
            index = 0
        }
        index += 1
        if index > len(command_history.entries) - 1 {
            index = 0
        }
        text := command_history.entries[index].text
        self.args[carg.TEXT] = text
        self.args[carg.STEP] = index
        self.args[carg.CARET] = len(text)
    } else {
        textfield_input(self, action, pressed)
    }
    return true
}

update_console :: proc(self: ^window){
    console_location=self.origin
    console_size=self.size    
}

textarea_update_entries :: proc(self: ^component){
    if history == nil {
        return
    }
    self.entries = history.entries
    textarea_render(self)
}

ui_console_open :: proc(){
    if history == nil {
        fmt.println("console cannot be initialized")
        return
    }
    if console_window == nil {
        console_window = createWindow(console_location, console_size, "console")
        w:= console_window
        w.render = update_console
        textarea := create_textarea("textarea1", rl.Vector2{0, 0}, rl.Vector2{0.100, -55.100})
        textarea.render=textarea_update_entries
        textarea.margin={5, 5, 5, 2.5}
        textarea.args[carg.BACKGROUND] = rl.Color{255, 255, 200, 255}
        textarea.action=fill_textfield
        textarea.args[carg.SCROLLAMOUNT] = 1.0
        add_component(w, textarea)
        textfield := create_textfield("textfield1", "", rl.Vector2{0, 0}, rl.Vector2{0.100, 40})
        textfield.input = ui_console_text_input
        textfield.margin={5, 2.5, 5, 2.5}
        textfield.args[carg.STEP] = 0
        textfield.reference=textarea
        textfield.action=ui_enter_command
        focused_component=textfield
        add_component(w, textfield)
        textarea.reference=textfield
    } else {
        if len(windows) == 0 {
            fmt.println("console already open")
            return
        }
        if windows[len(windows)-1] == console_window {
            closeWindow(console_window)
        } else {
            makeHead(console_window)
        }
    }
}

ui_console_init :: proc(){
    history = new(component)
    history.args[carg.MAX] = 200
    command_history = new(component)
    command_history.args[carg.MAX] = 200
}