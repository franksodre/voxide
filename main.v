module main

import command  { parse_command }

fn main() {
	arg := parse_command() or {
		eprintln('voxide: Unable to parse command.')
		exit(1)
	}
	arg.execute() or {
		eprintln('voxide: ${err}')
		exit(1)
	}
}
