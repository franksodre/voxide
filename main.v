module main

import command  { parse_command }
import os

fn main() {
  os.mkdir_all(os.dir(command.db_path)) or {
    eprintln(err)
    exit(1)
  }

  arg := parse_command() or {
		eprintln('voxide: Unable to parse command.')
		exit(1)
	}

	arg.execute() or {
		eprintln('voxide: ${err}')
		exit(1)
	}
}
