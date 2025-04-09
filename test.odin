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