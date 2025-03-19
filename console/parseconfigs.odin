package console

import "core:os"
import "core:fmt"
import "core:strings"



parse_file_for_cvars :: proc(filepath: string) {
	fmt.printf("Attempting to parse file: %s...\n", filepath)
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		console_error("Failed to read file: ", filepath)
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	    for line in strings.split_lines_iterator(&it) {
        data := strings.split(line, " ")
		if len(data) >1 {
			if isCommand(data[0]) {
				executeCommand(line)
			} else {
				setCvar(data[0], data[1])
			}
		}
	}
}
