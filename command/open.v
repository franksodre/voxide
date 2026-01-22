module command

import os
import database { open }

// am gonna make you useful path
// flag should handle subcommands, i'll handle it properly in future
struct Open implements Run {}

fn chdir(path string) {
}

pub fn (cmd Open) run() ! {
	mut db := open('file.db') or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(0)
	}
	defer { db.close() }

	path := os.args[2]
	// now := time.now().unix()

	db.query(path)!
}

// database connection
// get best matching path
// jump to the path location


