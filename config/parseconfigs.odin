package config

import "../console"
import "core:os"
import "core:fmt"
import "core:strings"

parse_file_for_cvars :: proc(filepath: string) {
	fmt.printf("Attempting to parse file: %s...\n", filepath)
	data, ok := os.read_entire_file(filepath, context.allocator)
	if !ok {
		fmt.println("Failed")
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		reg : console.CvarRegistry;
		data := strings.split(line, " ");
		console.RegisterCvar(&reg, data[0], console.CvarType.String, data[1], "randomvalue");
		
	}
}