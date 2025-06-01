package networking
import "../console"
import "core:net"
import "core:time"
import "core:container/queue"
import "core:fmt"
import rl "vendor:raylib"

local_client: ^Connection
to_local_server: [dynamic]Packet

Server :: struct {
	socket: net.UDP_Socket,
	endpoint: net.Endpoint,
	connections:  map[net.Endpoint]^Connection,
    islocal: bool,
    name: string,
    maxplayers: u16,
    mode: string,
}

ServerInfo :: struct {
    name: string,
    players: u16,
    maxplayers: u16,
    mode: string,
    address: string,
}

initialized_server: bool = false
server: ^Server

server_handle_packet :: proc(packet: Packet, conn: ^Connection) {
    conn.last_seen = rl.GetTime()

	if packet.header.flags == .Reliable && conn!=local_client {
		seq := packet.header.sequence

		if conn.received_acks[seq % 64] {
			// Duplicate — skip processing payload but still handle ack
			handle_ack(conn, packet.header.ack, packet.header.ack_bits)
            delete(packet.data)
			return
		}

		// Mark as seen
		conn.received_acks[seq % 64] = true

		if seq > conn.recv_sequence {
			conn.recv_sequence = seq
		}

		handle_ack(conn, packet.header.ack, packet.header.ack_bits)
	}
	messages:= decode_streamed_payload(packet.data, conn)
    fmt.println("messages: ", messages)
    for msg in messages {
        fmt.println("server_handle_message")
        server_handle_message(server, msg)
    }
    delete(messages)
    delete(packet.data)
}

server_listen :: proc() {
    if server == nil {
        return
    }
    if local_client != nil {
        for pkt in to_local_server {
            server_handle_packet(pkt, local_client)
            fmt.println("server_handle_packet: ", pkt)
        }
        clear(&to_local_server)
    }
    for {
        packet, from, err := receive_packet(server.socket)
        if err != nil || len(packet.data) == 0 {
            return
        }
        conn := server_establish_connection(server, from)
        server_handle_packet(packet, conn)
    }
	for _,conn in server.connections {
        resend_unacked_packets(conn, server.socket, 0.3)
    }
}

server_broadcast_reliable :: proc(server: ^Server, payload: [dynamic]u8) {
    
    for _, &conn in server.connections {
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
        send_packet_reliable(server.socket, packet, conn)
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
        send_packet(server.socket, packet, conn)
    }
}

server_establish_connection :: proc(server: ^Server, from: net.Endpoint) -> ^Connection {
    conn := server.connections[from]
    if conn == nil {
        conn = create_connection(from)
        console.log("New connection: [", from, "]")
    }
    conn.connected = true
    return conn
}


// Server Creation
create_server :: proc(name: string, maxplayers: u16, mode: string, port: int, islocal: bool) {
    server_close()
    
    address := net.IP4_Any // or net.IP4_Any for LAN games
    endpoint := net.Endpoint{
        address=address,
        port=port,
    }

    
    result := new(Server)
    if !islocal {
        socket, err := net.make_bound_udp_socket(address, port)
        assert(err == nil)
        net.set_blocking(socket, false)
        net.set_option(socket, .Broadcast, true)
        console.log("Listening on: ", endpoint)
        result.socket = socket
    }
    result.islocal = islocal
    result.name = name
    result.maxplayers = maxplayers
    result.mode = mode
    result.endpoint = endpoint
    server = result
}

server_close :: proc() {
    if server != nil {
        for _, &conn in server.connections {
            for _, packet in conn.sent_packets {
                delete(packet.data)
            }
            delete(conn.sent_packets)
            free(conn)
            
        }
        delete(server.connections)
        net.close(server.socket)
        free(server)
    }
}
