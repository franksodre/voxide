module command
import os

pub interface Run {
	run() !
}

pub type Command =
	Show  	|
	Query 	|
	Remove  |
	Add

pub fn (cmd Command) execute() ! {
	match cmd {
		Show 	{ cmd.run()! }
		Query 	{ cmd.run()! }
		Remove { cmd.run()! }
		Add 	{ cmd.run()! }
	}
}

pub fn parse_command() ?Command {
	arg := os.args[1]

	return match arg {
		'show' { Show{} }
		'query' { Query{} }
		'remove' { Remove{} }
		'add' { Add{} }
		else { none }
	}
}
