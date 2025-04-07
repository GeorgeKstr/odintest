package odintest

import "ui"
import "console"
import "defs"
import rl "vendor:raylib"
import "core:fmt"
import "networking"
import "core:strings"

ui_log::proc (args: ..any, sep := " ", flush := true) {
    ui.add_entry(ui.history, fmt.aprint(..args), rl.Color{0,0,0,0})
}

ui_error::proc (args: ..any, sep := " ", flush := true) {
    ui.add_entry(ui.history, fmt.aprint(..args), rl.RED)
}

ui_warn::proc (args: ..any, sep := " ", flush := true) {
    ui.add_entry(ui.history, fmt.aprint(..args), rl.YELLOW)
}

initialize_all :: proc() {
    ui.history = new(ui.component)
    ui.history.args[ui.carg.MAX] = 200
    console.ui_log = ui_log
    console.ui_error = ui_error
    console.ui_warn = ui_warn
    console.registerCommand("bind", proc(args: []string) {
		ui.bindKeyToAction(args[0], ui.action_names[args[1]])
	}, "binds a key to user action", 2)

    console.registerCommand("server", proc(args: []string) {
        is_server = true
        console.log("server called")
    }, "starts the server", 0)
    console.registerCommand("serveroff", proc(args: []string) {
        is_server = false
    }, "stops the server", 0)
    console.registerCommand("say", proc(args: []string) {
        networking.client_talk(strings.join(args, " "))
    }, "sends a message to the server", 999)
    console.parse_file_for_cvars("config.cfg")
    console.log_error("Initializing UI...")
    ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
}