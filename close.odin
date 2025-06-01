package odintest

import "ui"
import "networking"
import "console"

close_all :: proc () {
    ui.close_all()
    networking.close_all()
    console.clearRegistry()
}