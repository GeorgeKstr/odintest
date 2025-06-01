package odintest

import rl "vendor:raylib"
import "defs"
import "ui"
import io "fileio"
import "core:fmt"
import "core:os"
import "console"
import "networking"
import "core:mem"
import "back"

is_server := false
is_client := false

main :: proc() {
	track: back.Tracking_Allocator
	back.tracking_allocator_init(&track, context.allocator)
	defer back.tracking_allocator_destroy(&track)

	context.allocator = back.tracking_allocator(&track)
	defer back.tracking_allocator_print_results(&track)
	//w.flags[ui.windowFlags.WINDOW_FLAG_BORDERLESS] = true

	rl.InitWindow(1280, 720, "test")
	initialize_all()
	rl.SetTextLineSpacing(12)
	rl.SetTargetFPS(15)
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		if is_server {
			networking.server_listen()
		}
		if is_client {
			networking.client_listen()
		}
		ui.drawWindows()
		ui.checkInput()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
	rl.UnloadFont(ui.ui_font)
	io.unload_textures()
	ui.clearInput()
	close_all()
	rl.CloseWindow()
}