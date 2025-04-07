package networking

import "core:fmt"
import "core:mem"
import "core:net"
import "core:strings"
import "core:container/queue"
import "core:time"
import rl "vendor:raylib"

// Config
version: u8 = 0x42
shared_key: string = "SECRET_KEY_XOR"


Connection :: struct {
    socket: net.UDP_Socket,
    peer: net.Endpoint,

    send_sequence: u16,
    recv_sequence: u16,

    sent_packets: map[u16]Sent_Packet,

    received_acks: [64]bool,
	
	last_seen: f64,
    connected: bool,
}


create_connection :: proc(from: net.Endpoint) -> ^Connection {

	n := new(Connection)
	n.peer = from
	n.send_sequence = 0
	n.recv_sequence = 0
	n.last_seen = rl.GetTime()
	n.connected = true

	return n
}

send_packet :: proc(sock: net.UDP_Socket, packet: Packet, to: net.Endpoint) {
	encrypted := encrypt(packet)
	_, err := net.send_any(sock, encrypted, to)
}

send_reliable_packet :: proc(sock: net.UDP_Socket, packet: Packet, conn: ^Connection) {
    header := Packet_Header{
        version = version,
        flags = .Reliable,
        sequence = conn.send_sequence,
        ack = conn.recv_sequence,
        ack_bits = generate_ack_bits(conn),
    }

    packet := packet
	packet.header = header

	encoded := encrypt(packet)
	_, err := net.send_any(sock, encoded, conn.peer)
    conn.sent_packets[conn.send_sequence] = Sent_Packet{
        sequence = conn.send_sequence,
        data = encoded,
        timestamp = rl.GetTime(),
    }

    conn.send_sequence += 1
}

receive_packet :: proc(sock: net.UDP_Socket) -> (Packet, net.Endpoint, net.Network_Error) {
	buf: [1024]u8
	n, from, err := net.recv_udp(sock, buf[:])
	if err != nil || n == 0 {
		return Packet{}, from, err
	}
	return decrypt(buf), from, err
}

generate_ack_bits :: proc(conn: ^Connection) -> u32 {
    base := conn.recv_sequence
    bits: u32 = 0

    for i: u32; i < 32; i += 1 {
        seq: u16 = base - cast(u16)(i + 1)
        index := seq % 64
        if conn.received_acks[index] {
            bits |= (1 << i)
        }
    }

    return bits
}

resend_unacked_packets :: proc(conn: ^Connection, sock: net.UDP_Socket, timeout_ms: f64) {
    now := rl.GetTime()

    for seq, sent in conn.sent_packets {
        if now - sent.timestamp > timeout_ms {
            net.send_any(sock, sent.data, conn.peer)
            sp := conn.sent_packets[seq]
            sp.timestamp = now
        }
    }
}