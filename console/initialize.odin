package console
import "../ui"
import "../input"
import "../defs"
import rl "vendor:raylib"

initializeConsoleVars :: proc() {
    registerCommand("bind", proc(args: []string) {
		input.bindKeyToAction(args[0], input.action_names[args[1]])
	}, "binds a key to user action", 2)
    parse_file_for_cvars("config.cfg")
    ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
}