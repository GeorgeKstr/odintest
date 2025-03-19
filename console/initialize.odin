package console
import "../ui"
import "../defs"
import rl "vendor:raylib"

initializeConsoleVars :: proc() {
    ui.history = new(ui.component)
    ui.history.args[ui.carg.MAX] = 20
    registerCommand("bind", proc(args: []string) {
		ui.bindKeyToAction(args[0], ui.action_names[args[1]])
	}, "binds a key to user action", 2)
    parse_file_for_cvars("config.cfg")
    ui.ui_font = rl.LoadFontEx(defs.ui_font, defs.header_fontsize, nil, 0)
}