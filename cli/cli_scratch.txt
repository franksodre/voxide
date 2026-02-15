// handle cli stuff at glance
module cli

import os
import command { Command }

const home = os.home_dir()

// empty input
// wrong format
// is abs path?
// are they multiple matches?

struct Cli {
	input []string
}

fn new_cli() Cli {
	return Cli{
		input: os.args
	}
}

pub fn (c Cli) is_empty() bool {
	return if c.input.len == 0 { true } else { false }
}

pub fn parse_command() ?Command {
	arg := os.args[1]

	return match arg {
		'show' { Show{} }
		'open' { Open{} }
		'remove' { Remove{} }
		else { none }
	}
}
