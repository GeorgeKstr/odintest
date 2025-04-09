package networking

import "core:fmt"
import "core:strings"
import "core:net"
import "core:mem"
import "../console"


client_send_chat :: proc (message: string) {
    payload:[dynamic]u8
    append(&payload, ..write_string(client.username)[:])
    append(&payload, ..write_string(message)[:])
    message := Message{
        message_type= .Chat,
        sender= nil,
        data= payload[:],
    }
    send_message_reliable(client.socket, client.connection, message)
}

request_connect :: proc (address: string) {
    server_endpoint, ok := net.parse_endpoint(address)
    if ok == false {
        console.log("Failed to parse server endpoint")
        return
    }
    client.connection=client_establish_connection(client, server_endpoint)
    conn := client_establish_connection(client, server_endpoint)
    message := Message{
        message_type= .Connect,
        sender= nil,
        data= write_string(client.username)[:],
    }
    send_message_reliable(client.socket, conn, message)
}