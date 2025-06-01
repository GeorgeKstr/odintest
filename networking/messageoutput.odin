package networking

import "core:fmt"
import "core:strings"
import "core:net"
import "core:mem"
import "../console"


client_send_chat :: proc (message: string) {
    payload:[dynamic]u8
    write_string(&payload, client.username)
    write_string(&payload, message)
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
    conn := client.connection
    replydata:[dynamic]u8
    write_string(&replydata, client.username)
    message := Message{
        message_type= .Connect,
        sender= nil,
        data= replydata[:],
    }
    send_message_reliable(client.socket, conn, message)
}

connect_to_self :: proc () {
    if server == nil {
        console.log_error("Local server has not been initialized")
        return
    }
    fmt.println("Connecting locally...")
    conn := create_connection(net.Endpoint{})
    local_client=conn
    conn2 := create_connection(net.Endpoint{})
    local_server=conn2
    client.connection=conn2
    replydata:[dynamic]u8
    write_string(&replydata, "malakas")
    message := Message{
        message_type= .Connect,
        sender= nil,
        data= replydata[:],
    }
    send_message_reliable(client.socket, conn2, message)
}