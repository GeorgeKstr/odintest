package networking
import "core:fmt"
import "core:strings"
import "core:time"
import "core:net"
import "core:mem"
import "../console"
import "../ui"
import rl "vendor:raylib"

server_handle_message :: proc(server: ^Server, message: Message) {
    msg := message
    if msg.sender == nil {
        return
    }
    if msg.message_type == .Connect {
        username:= read_string(&msg.data)
        if u16(len(server.connections)) >= server.maxplayers {
            console.log("Could not accept connection from ", username, ", reason: Server is full")
            send_message_reliable(server.socket, message.sender, Message{
                message_type= .Disconnect,
                sender= message.sender,
                data= write_string("Server is full")[:],
            })
            return
        } else {
            console.log("received connection request from ", msg.sender.peer)
            server.connections[msg.sender.peer] = message.sender
            server.connections[msg.sender.peer].username = username
            message := Message{
                message_type= .Connect,
                sender= message.sender,
                data= []u8{},
            }
            send_message_reliable(server.socket, message.sender, message)
        }
    }
    if msg.message_type != .Discover && server.connections[msg.sender.peer] == nil {
        return
    }
    #partial switch msg.message_type {
        case .Discover:
            replydata : [dynamic]u8
            append(&replydata, ..write_string(server.name)[:])
            append(&replydata, ..write_u16(u16(len(server.connections)))[:])
            append(&replydata, ..write_u16(server.maxplayers)[:])
            append(&replydata, ..write_string(server.mode)[:])
            reply := Message{
                message_type= .Serverinfo,
                sender= message.sender,
                data= replydata[:],
            }
            send_message_reliable(server.socket, message.sender, reply)  
        case .Chat:
            payload := build_streamed_payload([]Message{
                message,
            })
            server_broadcast_reliable(server, payload)

            
    }
}

client_handle_message :: proc(client: ^Client, message: Message) {
    msg := message
    if msg.sender == nil {
        return
    }
    #partial switch msg.message_type {
        case .Connect:
            client.connected = true
            console.log("Connected to server")
        case .Serverinfo:
            serverinfo := ServerInfo {
                name= read_string(&msg.data),
                players= read_u16(&msg.data),
                maxplayers= read_u16(&msg.data),
                mode= read_string(&msg.data),
            }
            console.log("Server info: ", serverinfo)
        case .Chat:
            username:= read_string(&msg.data)
            text:=read_string(&msg.data)
            console.log("[", username, "]: ", text)
        case .Disconnect:
            w := ui.createWindow(rl.Vector2{0.5, 0.5}, rl.Vector2{400, 200}, "Disconnected")
            reason:=strings.concatenate([]string{"Reason: ", read_string(&msg.data)})
            label := ui.create_label("label1", reason, rl.Vector2{0, 0}, rl.Vector2{0.100, -45.100})
            label.args[ui.carg.CENTERED] = true
            ui.add_component(w, label)
            btn := ui.create_button("button1", "OK", rl.Vector2{-5.100, 0}, rl.Vector2{80, 40})
            ui.add_component(w, btn)
            initialized_client = false

    }
    
}