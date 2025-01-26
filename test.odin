package odintest

import rl "vendor:raylib"
import "defs"
import "ui"
import "config"
import "core:fmt"
import "core:os"

main :: proc() {
	config.parse_file_for_cvars("config.cfg")
	fmt.println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
	w:=ui.createWindow(rl.Vector2{5, 5}, rl.Vector2{500, 400}, "first window")
	w2:=ui.createWindow(rl.Vector2{50, 50}, rl.Vector2{90, 90}, "second window")
	w2.flags[ui.windowFlags.W_RELATIVETOSCREEN] = true
	//w.flags[ui.windowFlags.WINDOW_FLAG_BORDERLESS] = true
	rl.InitWindow(1280, 720, "test")
	
	ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
	rl.SetTextLineSpacing(12)
	rl.SetTargetFPS(60)
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		//fmt.println(cont.font)
		ui.DrawWindows()
		rl.EndDrawing()
	}
	rl.UnloadFont(ui.ui_font)
	ui.unload_textures()
	rl.CloseWindow()
}