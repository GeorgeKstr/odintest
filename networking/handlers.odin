package networking
import "core:fmt"
import "core:strings"
import "core:time"
import "core:net"
import "core:mem"
import "../console"

server_handle_message :: proc(server: ^Server, message: Message) {
    msg := message
    if msg.sender == nil {
        return
    }
    if msg.message_type != .Discover && server.connections[msg.sender.peer] == nil {
        return
    }
    #partial switch msg.message_type {
        case .Discover:
            replydata : [dynamic]u8
            append(&replydata, ..write_u16(server.maxplayers)[:])
            append(&replydata, ..write_string(server.mode)[:])
            append(&replydata, ..write_string(server.name)[:])
            reply := Message{
                message_type= .Serverinfo,
                sender= message.sender,
                data= replydata[:],
            }
            payload := build_streamed_payload([]Message{reply})
            packet := Packet{
                header = Packet_Header{
                    sequence = message.sender.send_sequence,
                    ack = message.sender.recv_sequence,
                    ack_bits = generate_ack_bits(message.sender),
                    version = version,
                    flags = Packet_Type.Reliable,
                },
                data = payload,
            }
            send_reliable_packet(server.socket, packet, message.sender)

        case .Chat:
            console.log("received chat message: ", msg.data)
            payload:[dynamic]u8
            append(&payload, ..msg.data[:])
            server_broadcast_reliable(server, payload)
    }
}

client_handle_message :: proc(client: ^Client, message: Message) {
    msg := message
    if msg.sender == nil {
        return
    }
    #partial switch msg.message_type {
        case .Chat:
            username:= read_string(&msg.data)
            text:=read_string(&msg.data)
            console.log("[", username, "]: ", text)
        case .Serverinfo:
            serverinfo := ServerInfo {
                name= read_string(&msg.data),
                maxplayers= read_u16(&msg.data),
                mode= read_string(&msg.data),
            }
            console.log("Server info: ", serverinfo)
    }
    
}