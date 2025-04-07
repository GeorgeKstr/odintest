package networking
import "core:net"
import "core:time"
import "../console"
import "core:fmt"
import rl "vendor:raylib"

initialized_client: bool = false
client: ^Client

client_listen :: proc() {
	if client == nil {
		init_client()
	}

	packet, from, err := receive_packet(client.socket)
	if err != nil || len(packet.data) == 0 {
		return
	}

	conn := client_establish_connection(client, from)
	conn.last_seen = rl.GetTime()
	client.last_received = rl.GetTime()

	if packet.header.flags == .Reliable {
		seq := packet.header.sequence

		if conn.received_acks[seq % 64] {
			handle_ack(conn, packet.header.ack, packet.header.ack_bits)
			return
		}

		conn.received_acks[seq % 64] = true

		if seq > conn.recv_sequence {
			conn.recv_sequence = seq
		}

		handle_ack(conn, packet.header.ack, packet.header.ack_bits)
	}
    resend_unacked_packets(conn, client.socket, 0.3)
}

client_talk :: proc(msg: string) {
    if client == nil {
        init_client()
    }
    conn := client_establish_connection(client, client.server_endpoint)
    client.last_sent = rl.GetTime()
    data := transmute([]u8)msg
    message := Message{
        message_type= .Chat,
        sender= conn,
        data= data,
    }
    msgs := []Message{message}
    payload:= build_streamed_payload(msgs)
    packet := Packet{
        header = Packet_Header{
            sequence = conn.send_sequence,
            ack = conn.recv_sequence,
            ack_bits = generate_ack_bits(conn),
            version = version,
            flags = Packet_Type.Reliable,
        },
        data = payload,
    }
    console.log("Sending message: ", msg)
    send_reliable_packet(client.socket, packet, conn)
}

init_client :: proc() {
    endpoint := net.Endpoint{}
    endpoint.address = net.IP4_Loopback
    endpoint.port = 7777
    client = create_client(endpoint.address, endpoint.port)
}

Client :: struct {
    socket: net.UDP_Socket,       // Local socket for sending/receiving
    server_endpoint: net.Endpoint,// IP/port of the server
    connection: ^Connection,       // Reliable connection tracking (seq, ack, etc.)

    connected: bool,
    last_received: f64,
    last_sent: f64,
}


client_establish_connection :: proc(client: ^Client, from: net.Endpoint) -> ^Connection {
    conn := client.connection
    if conn == nil {
        conn := create_connection(from)
        client.connection = conn
        console.log("New connection: [", from, "]")
    } else if conn.peer != from {
        console.log("New connection: [", from, "]")
        conn.peer = from
    }
    return conn
}

create_client :: proc(server_ip: net.Address, server_port: int) -> ^Client {
    // Bind to any free port on the local machine
    local_addr := net.IP4_Loopback // or net.IP4_Any if you want LAN support
    local_port := 0 // OS assigns random port

    socket, err := net.make_bound_udp_socket(local_addr, local_port)
    assert(err == nil)

    net.set_blocking(socket, false)

    server_endpoint := new(net.Endpoint)
    server_endpoint.address = server_ip
    server_endpoint.port = server_port

    connection := new(Connection)
    connection.peer = server_endpoint^
    connection.send_sequence = 0
    connection.recv_sequence = 0
    connection.sent_packets = map[u16]Sent_Packet{}
    connection.received_acks = [64]bool{}
    fmt.println("Sending message: ")
    
    client := new(Client)
    client.socket = socket
    client.server_endpoint = server_endpoint^
    client.connection = connection
    client.connected = false
    client.last_received = rl.GetTime()
    client.last_sent = rl.GetTime()
    return client
}