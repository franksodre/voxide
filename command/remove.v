module command

import os
import database { open }

pub struct Remove implements Run {}

pub fn (cmd Remove) run() ! {
	mut db := open('file.db') or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(0)
	}
	defer { db.close() }
	db.delete(os.args[2])!
}
