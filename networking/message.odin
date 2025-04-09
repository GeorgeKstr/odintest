package networking
import "core:fmt"
import "core:strings"
import "core:time"
import "core:net"
import "core:mem"
import "../console"

Message_Type:: enum u8 {
	Discover,
	Connect,
	Disconnect,
	Serverinfo,
	Error,
	Chat,
	Input,
	Update,
}

Message :: struct {
    sender: ^Connection,
    message_type: Message_Type,
    data: []u8,
}

build_streamed_payload :: proc(messages: []Message) -> [dynamic]u8 {
    out: [dynamic]u8
    for msg in messages {
        append(&out, u8(msg.message_type))
        length_bytes := len(msg.data)
        append(&out, cast(u8)(length_bytes >> 8))
        append(&out, cast(u8)(length_bytes & 0xFF))
        append(&out, ..msg.data[:])
    }
    return out
}

decode_streamed_payload :: proc(buf: [dynamic]u8, conn: ^Connection) -> [dynamic]Message {
	messages: [dynamic]Message
	i := 0

	for i < len(buf) {
		if i + 3 > len(buf) {
			break
		}

		msg_type := cast(Message_Type)(buf[i])
		length := (u16(buf[i+1]) << 8) | u16(buf[i+2])
		i += 3

		if i + int(length) > len(buf) {
			break // not enough for payload
		}

		data := buf[i : i + int(length)] // ✅ fixed colon
		i += int(length)

		msg := Message{
			message_type = msg_type,
			data = data,
			sender = conn,
		}
		append(&messages, msg)
	}

	return messages
}

write_string :: proc(str: string) -> []u8 {
	out : [dynamic]u8
	length := len(str)
	append(&out, cast(u8)(length >> 8))
	append(&out, cast(u8)(length & 0xFF))
	append(&out, ..transmute([]u8)str[:])
	return out[:]
}

read_string :: proc(buf: ^[]u8) -> string {
	length := (u16((buf^)[0]) << 8) | u16((buf^)[1])
	result := string((buf^)[2 : 2 + int(length)])
	buf^ = (buf^)[2 + int(length) : ]
	return result
}

write_u16 :: proc(num: u16) -> []u8 {
	out : [dynamic]u8
	append(&out, cast(u8)(num >> 8))
	append(&out, cast(u8)(num & 0xFF))
	return out[:]
}

read_u16 :: proc(buf: ^[]u8) -> u16 {
	result := (u16((buf^)[0]) << 8) | u16((buf^)[1])
	buf^ = (buf^)[2 : ]
	return result
}

send_message_reliable :: proc(socket: net.UDP_Socket, conn: ^Connection, msg: Message) {
	packet := Packet{
		header = Packet_Header{
			sequence = conn.send_sequence,
			ack = conn.recv_sequence,
			ack_bits = generate_ack_bits(conn),
			version = version,
			flags = Packet_Type.Reliable,
		},
		data = build_streamed_payload([]Message{msg}),
	}
	send_packet_reliable(socket, packet, conn)
}