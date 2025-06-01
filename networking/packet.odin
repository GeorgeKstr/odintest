package networking

import "core:mem"
import "core:time"
import "core:fmt"
import "../console"

Packet_Type :: enum u8 {
	Unreliable,
	Reliable,
}

Packet_Header :: struct {
    sequence: u16,    // this packet's ID
    ack: u16,         // last packet received from peer
    ack_bits: u32,    // which of the last 32 packets were received
    version: u8,
    flags: Packet_Type,
}

Sent_Packet :: struct {
    sequence: u16,
    timestamp: f64,
    data: []u8,
}

// Core Types
Packet :: struct {
    header: Packet_Header,
    data: [dynamic]u8, // Your payload (chat, position, etc.)
}

encrypt :: proc(p: Packet) -> []u8 {
	out: [dynamic]u8

	// Append header fields manually (instead of append_struct)
	append(&out, p.header.version)
	append(&out, cast(u8)p.header.flags)
	append(&out, cast(u8)(p.header.sequence >> 8))
	append(&out, cast(u8)(p.header.sequence & 0xFF))
	append(&out, cast(u8)(p.header.ack >> 8))
	append(&out, cast(u8)(p.header.ack & 0xFF))

	// 4 bytes for ack_bits (big endian)
	append(&out, cast(u8)((p.header.ack_bits >> 24) & 0xFF))
	append(&out, cast(u8)((p.header.ack_bits >> 16) & 0xFF))
	append(&out, cast(u8)((p.header.ack_bits >> 8) & 0xFF))
	append(&out, cast(u8)(p.header.ack_bits & 0xFF))

	// XOR encrypt data
	for i in 0..<len(p.data) {
		append(&out, p.data[i] ~ shared_key[i % len(shared_key)])
	}
	//console.log("Sending packet: ", p)
	return out[:]
}

decrypt :: proc(buf: [1024]u8) -> Packet {
	p := Packet{}

	if len(buf) < 10 {
		fmt.println("decrypt: invalid buffer length")
		return p
	}

	p.header.version  = buf[0]
	p.header.flags    = cast(Packet_Type)(buf[1])

	p.header.sequence = (cast(u16)(buf[2]) << 8) | cast(u16)(buf[3])
	p.header.ack      = (cast(u16)(buf[4]) << 8) | cast(u16)(buf[5])

	p.header.ack_bits =
		(cast(u32)(buf[6]) << 24) |
		(cast(u32)(buf[7]) << 16) |
		(cast(u32)(buf[8]) << 8)  |
		cast(u32)(buf[9])

	data_len := len(buf) - 10
	for i in 0..<data_len {
		xor := buf[10 + i] ~ shared_key[i % len(shared_key)]
		append(&p.data, xor)
	}
	return p
}


handle_ack :: proc(conn: ^Connection, ack: u16, ack_bits: u32) {
	pkt := conn.sent_packets[ack]
	delete(pkt.data)
    delete_key(&conn.sent_packets, ack)

    for i: u32; i < 32; i += 1 {
        if (ack_bits & (1 << i)) != 0 {
            seq := ack - cast(u16)(i + 1)
			pkt = conn.sent_packets[seq]
			delete(pkt.data)
            delete_key(&conn.sent_packets, seq)
        }
    }
}
