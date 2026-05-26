module command

import cli
import database { open }

pub fn run_remove(cmd cli.Command) ! {
	mut db := open(db_path) or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(0)
	}
	// defer { db.close() }
	db.delete(cmd.args[0]) or {
		eprintln("voxide: failed to `delete` path.")
		exit(1)
	}

	println("voxide: path deleted.")
}
