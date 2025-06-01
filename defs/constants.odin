package defs
import rl "vendor:raylib"
import "core:strings"
import "core:mem"

header_height :: 32
header_fontsize ::20
ui_font :: "assets/ui/fonts/sangyo.ttf"
data_union :: union {
    string,
    bool,
    f32,
    rl.Vector3,
    rl.Color,
    int,
}

data_union_delete :: proc(self: ^data_union) {
    #partial switch i in self {
        case string:
            delete(self^.(string))
    }
}