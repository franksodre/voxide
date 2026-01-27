module command
import os

pub interface Run {
	run() !
}

pub type Command = Show | Open | Remove

pub fn (cmd Command) execute() ! {
	match cmd {
		Show 	{ cmd.run()! }
		Open 	{ cmd.run()! }
		Remove { cmd.run()! }
	}
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
