package console

import "core:fmt"
import rl "vendor:raylib"

ui_log: proc(args: ..any, sep := " ", flush := true)
ui_error: proc(args: ..any, sep := " ", flush := true)
ui_warn: proc(args: ..any, sep := " ", flush := true)
ui_cmd: proc(args: ..any, sep := " ", flush := true)

log :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    if ui_log != nil {
        ui_log(..args)
    }
}

log_error :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    if ui_error != nil {
        ui_error(..args)
    }
}

log_warn :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    if ui_warn != nil {
        ui_warn(..args)
    }
}

log_cmd :: proc(args: ..any, sep := " ", flush := true) {
    fmt.println(..args)
    if ui_cmd != nil {
        ui_cmd(..args)
    }
}
