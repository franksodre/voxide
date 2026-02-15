module command

import os
import time
import database { Database, open }

const path_separator = '/'

struct Query implements Run {
	args []string
mut:
	conn Database
}

// am not sure about this
fn new_query() !&Query {
	args := os.args[2..]
	mut db := open(db_path) or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(1)
	}

	db.create()!

	return &Query{
		args: args
		conn: db
	}
}

pub fn (o Query) query() ! {
	args := o.args
	now := time.now().unix()

	if args.len == 0 {
		eprintln("voxide: A path must be provided [you don't go straight to home yet].")
		exit(1)
	}

	cwd := os.getwd()
	entries := os.ls(cwd) or { [] }
	mut dir_path := ''
	if args.len == 1 {
		for entry in entries {
			dir := os.join_path_single(cwd, entry)
			if os.is_dir(dir) {
				dir_name := dir.split(path_separator).last()

				if dir_name == args[0] {
					dir_path = dir
					break
				}
			}
		}
	}

	if args[0].contains(path_separator) {
		path := path_exists(args[0]) or {
			eprintln(err)
			exit(1)
		}
		println(os.abs_path(path))
	} else if dir_path == '' {
		// this may not work as expected
		mut current := o.conn.find_files(args[0]) or {
			eprintln('voxide: no match found')
			exit(1)
		}

		if args.len > 1 {
			for arg in args[1..] {
				if current.len == 0 {
					break
				}
				current = intersect(current, o.conn.find_files(arg)!)
			}
		}

		// sort by score
		current.sort_files_by_score(now)

		mut matched_file := false
		for file in current {
			// to_lower is really necessary, i determine what's necessary and what's not.
			dir_name := get_dir_name(file.path).to_lower()
			if dir_name.starts_with(args[0].to_lower()) {
				matched_file = true
				println(file.path)
				break
			}
		}

		// ugly but works
		if !matched_file {
			curr := current[0] or {
				eprintln('voxide: no match found')
				exit(1)
			}
			println(curr.path)
		}
	} else {
		println(dir_path)
	}
}

pub fn (cmd Query) run() ! {
	query := new_query()!
	query.query()!
}
