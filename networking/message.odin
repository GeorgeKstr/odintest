package networking
import "core:fmt"
import "core:strings"
import "core:time"
import "core:net"
import "core:mem"
import "../console"

Message_Type:: enum u8 {
	Connect,
	Disconnect,
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

decode_streamed_payload :: proc(buf: [dynamic]u8) -> [dynamic]Message {
	messages: [dynamic]Message
	i := 0

	for i < len(buf) {
		if i + 3 > len(buf) {
			break
		}

		msg_type := cast(Message_Type)(buf[i])
		console.log("Message type: ", msg_type)
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
		}
		append(&messages, msg)
	}

	return messages
}
