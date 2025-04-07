package networking
import "../console"
import "core:net"
import "core:time"
import "core:container/queue"
import "core:fmt"
import rl "vendor:raylib"

initialized_server: bool = false
server: ^Server

server_handle_packet :: proc(server: ^Server, packet: Packet, conn: ^Connection) {
    console.log("called server_handle_packet")
    messages:= decode_streamed_payload(packet.data)
    for msg in messages {
        console.log("Message type: ", msg.message_type)
        #partial switch msg.message_type {
            case .Chat:
                console.log("Chat: ", string(msg.data))
        }
            
    }
}

server_listen :: proc() {
	if server == nil {
		server = create_server(7777)
	}

	packet, from, err := receive_packet(server.socket)
	if err != nil || len(packet.data) == 0 {
		return
	}

	conn := server_establish_connection(server, from)
	conn.last_seen = rl.GetTime()

	if packet.header.flags == .Reliable {
		seq := packet.header.sequence

		if conn.received_acks[seq % 64] {
			// Duplicate — skip processing payload but still handle ack
			handle_ack(conn, packet.header.ack, packet.header.ack_bits)
			return
		}

		// Mark as seen
		conn.received_acks[seq % 64] = true

		if seq > conn.recv_sequence {
			conn.recv_sequence = seq
		}

		handle_ack(conn, packet.header.ack, packet.header.ack_bits)
	}
    for _,conn in server.connections {
        resend_unacked_packets(conn, server.socket, 0.3)
    }
	server_handle_packet(server, packet, conn)
}

server_talk :: proc(msg: string, to: net.Endpoint) {
    if server == nil {
        server = create_server(7777)
    }
    conn := server_establish_connection(server, to)
    packet := Packet {
        header = Packet_Header {
            sequence = conn.send_sequence,
            ack = conn.recv_sequence,
            ack_bits = generate_ack_bits(conn),
            version = version,
            flags = Packet_Type.Reliable,
        },
        data = nil,
    }
    send_reliable_packet(server.socket, packet, conn)
}

server_broadcast_reliable :: proc(server: ^Server, payload: [dynamic]u8) {
    
    for _, conn in server.connections {
        packet := Packet {
            header = Packet_Header {
                sequence = conn.send_sequence,
                ack = conn.recv_sequence,
                ack_bits = generate_ack_bits(conn),
                version = version,
                flags = Packet_Type.Reliable,
            },
            data = payload,
        }
        send_reliable_packet(server.socket, packet, conn)
    }
}

server_broadcast_unreliable :: proc(server: ^Server, payload: [dynamic]u8) {
    for _, conn in server.connections {
        packet := Packet {
            header = Packet_Header {
                sequence = conn.send_sequence,
                ack = conn.recv_sequence,
                ack_bits = generate_ack_bits(conn),
                version = version,
                flags = Packet_Type.Unreliable,
            },
            data = payload,
        }
        send_packet(server.socket, packet, conn.peer)
    }
}

server_establish_connection :: proc(server: ^Server, from: net.Endpoint) -> ^Connection {
    conn := server.connections[from]
    if conn == nil {
        conn = create_connection(from)
        server.connections[from] = conn
        console.log("New connection: [", from, "]")
    }
    conn.connected = true
    return conn
}

Server :: struct {
	socket: net.UDP_Socket,
	endpoint: net.Endpoint,
	connections:  map[net.Endpoint]^Connection,
	global_packets: queue.Queue(^Packet),
}

// Server Creation
create_server :: proc(port: int) -> ^Server {
    address := net.IP4_Loopback // or net.IP4_Any for LAN games
    endpoint := new(net.Endpoint)
    endpoint.address = address
    endpoint.port = port

    socket, err := net.make_bound_udp_socket(address, port)
    assert(err == nil)

    net.set_blocking(socket, false)

    console.log("Listening on: ", endpoint)

    result := new(Server)
    result.socket = socket
    result.endpoint = endpoint^
    return result
}
