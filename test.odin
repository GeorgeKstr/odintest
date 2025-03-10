package odintest

import rl "vendor:raylib"
import "defs"
import "ui"
import "core:fmt"
import "core:os"
import "console"

fill_console :: proc(self: ^ui.component, arg: defs.data_union){
	if self.reference != nil {
		if(self.reference.action!= nil){
			self.reference.action(self.reference, arg)
			self.args[ui.carg.TEXT] = ""
			self.args[ui.carg.CARET] = 0
		}
	}
}

main :: proc() {
	w:=ui.createWindow(rl.Vector2{5, 5}, rl.Vector2{500, 200+ui.headersize}, "first window")
	w2:=ui.createWindow(rl.Vector2{50, 50}, rl.Vector2{300, 400}, "second window")
	textarea := ui.create_textarea("textarea1", "demotext", rl.Vector2{0, 0}, rl.Vector2{0.100, -40.100})
	textarea.margin={5, 5, 5, 2.5}
	textarea.args[ui.carg.BACKGROUND] = rl.Color{255, 255, 200, 255}
	ui.add_component(w, textarea)
	textfield := ui.create_textfield("textfield1", "", rl.Vector2{0, 0}, rl.Vector2{0.100, 40})
	textfield.margin={5, 2.5, 5, 5}
	textfield.reference=textarea
	textfield.action=fill_console
	ui.add_component(w, textfield)

	//w.flags[ui.windowFlags.WINDOW_FLAG_BORDERLESS] = true
	rl.InitWindow(1280, 720, "test")
	rl.SetTextLineSpacing(12)
	rl.SetTargetFPS(60)
	console.initializeConsoleVars()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		ui.drawWindows()
		ui.checkInput()
		rl.EndDrawing()
	}
	rl.UnloadFont(ui.ui_font)
	ui.unload_textures()
	console.clearConsole()
	ui.clearInput()
	rl.CloseWindow()
}