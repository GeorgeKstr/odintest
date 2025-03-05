package defs
import rl "vendor:raylib"

header_height :: 32
header_fontsize ::20
ui_font :: "assets/ui/fonts/sangyo.ttf"
data_union :: union {
    string,
    rl.Vector3,
    rl.Color,
    int
}
