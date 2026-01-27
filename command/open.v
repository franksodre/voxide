module command

import os
import db.sqlite

import database { open }

const home_dir = os.home_dir()
const db_path = home_dir + '/Documents/Code/learn_v/notes_zoxide/file.db'

// am gonna make you useful path
// flag should handle subcommands, i'll handle it properly in future
struct Open implements Run {
	args []string
	conn sqlite.DB
}

// am not sure about this
fn new_open() !&Open {
	args := os.args

	mut db := open(db_path) or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(0)
	}

	db.create()!

	defer { db.close() }

	return &Open{
		args: args
		conn: db.db
	}
}


pub fn (o Open) query() ! {
	args := o.args
	if args.len == 0 {
			eprintln('voxide: A path must be provided.')
			exit(1)
		}
	for arg in args {
		println(arg)
	}
}

pub fn (cmd Open) run() ! {}
