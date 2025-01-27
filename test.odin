package odintest

import rl "vendor:raylib"
import "defs"
import "ui"
import "core:fmt"
import "core:os"
import "input"
import "console"

main :: proc() {
	w:=ui.createWindow(rl.Vector2{5, 5}, rl.Vector2{500, 400}, "first window")
	w2:=ui.createWindow(rl.Vector2{50, 50}, rl.Vector2{300, 400}, "second window")
	//w.flags[ui.windowFlags.WINDOW_FLAG_BORDERLESS] = true
	rl.InitWindow(1280, 720, "test")
	rl.SetTextLineSpacing(12)
	rl.SetTargetFPS(60)
	console.initializeConsoleVars()
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		ui.drawWindows()
		input.checkInput()
		rl.EndDrawing()
	}
	rl.UnloadFont(ui.ui_font)
	ui.unload_textures()
	console.clearConsole()
	input.clearInput()
	rl.CloseWindow()
}