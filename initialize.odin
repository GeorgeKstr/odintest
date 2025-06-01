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

ui_cmd::proc (args: ..any, sep := " ", flush := true) {
    ui.add_entry(ui.history, fmt.aprint(..args), rl.Color{173,216,230,255})
}

initialize_all :: proc() {
    console.ui_log = ui_log
    console.ui_error = ui_error
    console.ui_warn = ui_warn
    console.ui_cmd = ui_cmd
    ui.ui_init()
    console.initializeRegistry()
    console.registerCommand("bind", proc(args: []string) {
		ui.bindKeyToAction(args[0], ui.action_names[args[1]])
	}, "binds a key to user action", 2)
    console.registerCommand("server", proc(args: []string) {
        is_server = true
        networking.create_server("default", 3, "default", 26000, false)
        is_client = true
        networking.create_client_local()
        networking.connect_to_self()
    }, "starts the server", 0)
    console.registerCommand("serveroff", proc(args: []string) {
        is_server = false
    }, "stops the server", 0)
    console.registerCommand("say", proc(args: []string) {
        networking.client_send_chat(strings.join(args, " "))
    }, "sends a message to the server", 999)
    console.registerCommand("discover", proc(args: []string) {
        networking.discover_servers("255.255.255.255:26000")
    }, "pings local network to discover servers", 0)
    console.registerCommand("connect", proc(args: []string) {
        is_client = true
        networking.init_client()
        networking.request_connect(args[0])
    }, "connects to a server", 1)
    console.registerCommand("client", proc(args: []string) {
        is_client = true
        networking.init_client()
        networking.request_connect("127.0.0.1:26000")
    }, "starts the client", 0)
    console.parse_file_for_cvars("config.cfg")
    console.log_error("Initializing UI...")
    ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
}