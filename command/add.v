module command

import os
import time
import cli
import database { Database, open }

pub struct Add {
	path string
	mut:
		conn Database
}

// this is a bit useless inside here
fn new_add() !&Add {
	args := os.args[2]
	mut db := open(db_path) or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(0)
	}

	db.create()!

	return &Add {
		conn: db
		path: args
	}
}

fn (add Add) add() ! {
	file := add.conn.exists(add.path)!
	now := time.now().unix()
	incr_score := 1.0

	path := os.abs_path(add.path)

	if file {
		add.conn.update(path, incr_score, now)!
	} else {
		add.conn.add(path, incr_score, now)!
	}
}

pub fn run_add(cmd cli.Command) ! {
	cmd_add := new_add()!
	cmd_add.add()!
}
