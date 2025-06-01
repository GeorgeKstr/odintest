package networking

close_all :: proc() {
    if client != nil {
        client_close()
    }
    if server != nil {
        server_close()
    }
}