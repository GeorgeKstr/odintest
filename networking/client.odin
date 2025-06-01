package networking
import "core:net"
import "core:time"
import "../console"
import "core:fmt"
import rl "vendor:raylib"

initialized_client: bool = false
client: ^Client

local_server: ^Connection
to_local_client: [dynamic]Packet

Client :: struct {
    socket: net.UDP_Socket,       // Local socket for sending/receiving
    server_endpoint: net.Endpoint,// IP/port of the server
    connection: ^Connection,       // Reliable connection tracking (seq, ack, etc.)
    username: string,

    connected: bool,
    last_received: f64,
    last_sent: f64,
}

client_handle_packet :: proc(packet: Packet, conn: ^Connection) {
    conn.last_seen = rl.GetTime()
	client.last_received = rl.GetTime()
	if packet.header.flags == .Reliable && conn != local_server {
		seq := packet.header.sequence
		if conn.received_acks[seq % 64] {
			handle_ack(conn, packet.header.ack, packet.header.ack_bits)
            delete(packet.data)
			return
		}
		conn.received_acks[seq % 64] = true
		if seq > conn.recv_sequence {
			conn.recv_sequence = seq
		}
		handle_ack(conn, packet.header.ack, packet.header.ack_bits)
	}
    messages:= decode_streamed_payload(packet.data, conn)
    for msg in messages {
        client_handle_message(client, msg)
    }
    clear(&messages)
    delete(packet.data)
}

client_listen :: proc() {
	if client == nil {
		return
	}
    if local_server != nil {
        for pkt in to_local_client {
            client_handle_packet(pkt, local_server)
            fmt.println("client_handle_packet")
        }
        clear(&to_local_client)
    }
    for {
        packet, from, err := receive_packet(client.socket)
        if err != nil || len(packet.data) == 0 {
            return
        }
        conn := client_establish_connection(client, from)
        client_handle_packet(packet, conn)
        resend_unacked_packets(conn, client.socket, 0.3)
    }
}

init_client :: proc() {
    endpoint := net.Endpoint{}
    endpoint.address = net.IP4_Loopback
    endpoint.port = 7777
    client = create_client(endpoint.address, endpoint.port)
    client.username = "malakas"
}

create_client_local :: proc(){
    if client != nil {
        client_close()
    }
    c := new(Client)
    client = c
}

client_establish_connection :: proc(client: ^Client, from: net.Endpoint) -> ^Connection {
    client.server_endpoint = from
    conn := client.connection
    if conn == nil {
        client.connection = create_connection(from)
        conn = client.connection
    } else if conn.peer != from {
        conn.peer = from
        conn.send_sequence = 0
        conn.recv_sequence = 0
        conn.sent_packets = map[u16]Sent_Packet{}
        conn.received_acks = [64]bool{}
    }
    return conn
}

create_client :: proc(server_ip: net.Address, server_port: int) -> ^Client {

    if client != nil {
        client_close()
    }

    // Bind to any free port on the local machine
    local_addr := net.IP4_Any // or net.IP4_Any if you want LAN support
    local_port := 0 // OS assigns random port

    socket, err := net.make_bound_udp_socket(local_addr, local_port)
    assert(err == nil)

    net.set_blocking(socket, false)
    net.set_option(socket, .Broadcast, true)

    server_endpoint := net.Endpoint{
        address = server_ip,
        port = server_port
    }

    connection := new(Connection)
    connection.peer = server_endpoint
    connection.send_sequence = 0
    connection.recv_sequence = 0
    connection.sent_packets = map[u16]Sent_Packet{}
    connection.received_acks = [64]bool{}
    
    client := new(Client)
    client.socket = socket
    client.server_endpoint = server_endpoint
    client.connection = connection
    client.connected = false
    client.last_received = rl.GetTime()
    client.last_sent = rl.GetTime()
    return client
}

discover_servers :: proc(address: string) {
    broadcast_endpoint, endpoint_parsed := net.parse_endpoint(address)
    if endpoint_parsed == false {
        console.log("Failed to parse broadcast endpoint")
        return
    }
    payload := build_streamed_payload([]Message{
            Message{
                message_type= .Discover,
                sender= nil,
                data= nil,
            },
        })
    packet := Packet{
        header = Packet_Header{
            sequence = 0,
            ack = 0,
            ack_bits = 0,
            version = version,
            flags = Packet_Type.Reliable,
        },
        data = payload,
    }
    console.log("Pinging local network for servers...", broadcast_endpoint)
    conn2 := client_establish_connection(client, broadcast_endpoint)
    send_packet_reliable(client.socket, packet, conn2)
    delete(payload)
}

client_close :: proc() {
    if client == nil {
        return
    }
    for _, pkt in client.connection.sent_packets {
        delete(pkt.data)
    }
    free(client.connection)
    free(client)
    client = nil
}