package odintest

import rl "vendor:raylib"
import "defs"
import "ui"
import io "fileio"
import "core:fmt"
import "core:os"
import "console"
import "networking"

is_server := false
is_client := false

fill_console :: proc(self: ^ui.component, arg: defs.data_union){
	if self.reference != nil {
		ui.add_entry(self.reference, arg.(string), rl.RED)
		self.args[ui.carg.TEXT] = ""
		self.args[ui.carg.CARET] = 0
		
	}
}

fill_textfield :: proc(self: ^ui.component, arg: defs.data_union){
	if self.reference != nil {
		self.reference.args[ui.carg.TEXT] = arg.(string)
	}
}

printhello::proc(self: ^ui.component, arg: defs.data_union){
	fmt.println("hello")
}

main :: proc() {
	w:=ui.createWindow(rl.Vector2{5, 5}, rl.Vector2{500, 200+ui.headersize}, "first window")
	w2:=ui.createWindow(rl.Vector2{50, 50}, rl.Vector2{300, 400}, "second window")
	textarea := ui.create_textarea("textarea1", rl.Vector2{0, 0}, rl.Vector2{0.100, -100.100})
	textarea.args[ui.carg.MAX] = 20
	i:=0
	for i < 20 {
		text := "text text text text text text text text text text text text text text text text "
		i+=1
		color := rl.Color{u8(255), u8(0), u8(0), 255}
		if i%2 == 0 && i>13{
			color = rl.Color{u8(0), u8(255), u8(0), 255}
		}
		ui.add_entry(textarea, text, color)
	}
	textarea.margin={5, 5, 5, 2.5}
	textarea.args[ui.carg.BACKGROUND] = rl.Color{255, 255, 200, 255}
	textarea.action=fill_textfield
	textarea.args[ui.carg.SCROLLAMOUNT] = 1.0
	ui.add_component(w, textarea)
	textfield := ui.create_textfield("textfield1", "", rl.Vector2{0, 0}, rl.Vector2{0.100, 40})
	textfield.margin={5, 2.5, 5, 2.5}
	textfield.reference=textarea
	textfield.action=fill_console
	ui.add_component(w, textfield)

	textarea.reference=textfield
	
	button := ui.create_button("button1", "button", rl.Vector2{0, 0}, rl.Vector2{80, 40})
	button.margin={5, 2.5, 5, 5}
	button.action=printhello
	ui.add_component(w, button)

	checkbox := ui.create_checkbox("checkbox1", "Accept Terms", rl.Vector2{0, 0}, rl.Vector2{40, 40})
	checkbox.margin = {5, 2.5, 5, 5}
	checkbox.stack = .HORIZONTAL
	ui.add_component(w, checkbox)

	label := ui.create_label("label1", "Sample Label", rl.Vector2{0, 0}, rl.Vector2{120, 40})
	label.margin = {5, 2.5, 5, 5}
	label.args[ui.carg.BACKGROUND]=rl.RAYWHITE
	label.args[ui.carg.HOVER_COLOR]=rl.Color{255, 255, 200, 255}
	label.action=printhello
	label.stack = .HORIZONTAL
	ui.add_component(w, label)

	slider := ui.create_slider("slider1", 20, 10, 100, 5, rl.Vector2{0, 0}, rl.Vector2{200, 40})
	slider.margin={5, 2.5, 5, 5}
	slider.stack = .HORIZONTAL
	ui.add_component(w, slider)

	//w.flags[ui.windowFlags.WINDOW_FLAG_BORDERLESS] = true
	rl.InitWindow(1280, 720, "test")
	rl.SetTextLineSpacing(12)
	rl.SetTargetFPS(60)
	initialize_all()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		if is_server {
			networking.server_listen()
		} else {
			networking.client_listen()
		}
		ui.drawWindows()
		ui.checkInput()
		rl.EndDrawing()
	}
	rl.UnloadFont(ui.ui_font)
	io.unload_textures()
	console.clearConsole()
	ui.clearInput()
	rl.CloseWindow()
}