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
    }, "starts the server", 0)
    console.registerCommand("serveroff", proc(args: []string) {
        is_server = false
    }, "stops the server", 0)
    console.registerCommand("say", proc(args: []string) {
        payload:[dynamic]u8
        append(&payload, ..networking.write_string("gamias")[:])
        append(&payload, ..networking.write_string(strings.join(args, " "))[:])
        message := networking.Message{
            message_type= networking.Message_Type.Chat,
            sender= nil,
            data= payload[:],
        }
        packet_payload := networking.build_streamed_payload([]networking.Message{message})
        packet := networking.Packet{
            header = networking.Packet_Header{
                sequence = 0,
                ack = 0,
                ack_bits = 0,
                version = networking.version,
                flags = networking.Packet_Type.Reliable,
            },
            data = packet_payload,
        }
        networking.send_reliable_packet(networking.client.socket, packet, networking.client_establish_connection(networking.client, networking.client.server_endpoint))
    }, "sends a message to the server", 999)
    console.registerCommand("discover", proc(args: []string) {
        networking.discover_servers(args[0])
    }, "testing", 1)
    console.parse_file_for_cvars("config.cfg")
    console.log_error("Initializing UI...")
    ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
}