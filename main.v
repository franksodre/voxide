module main

import flag
import os
import time

import database

struct Config {
	add			string @[only: add; xdoc: 'adds a new path to the database']
	remove	string @[only: remove; xdoc: 'remove path from the database']
	// open 		string@[only: open; xdoc: 'opens a file']
	query		string @[only: query; xdoc: 'search for a path from the database']
}


fn main() {
	mut conn := database.open('file.db') or { panic(err) }

	// f := database.new_file('~/database/file.txt', 2, 120)
	// sql conn.db {
	// 	insert f into database.File
	// }!

	// all := sql conn.db {
	// 	select from database.File
	// }!
	// println(all)
	defer {
		conn.close()
	}

	config, no_matches := flag.to_struct[Config](os.args, skip: 1)!

	if no_matches.len > 0 {
		println('The following flags could not be mapped to any fields on the struct: ${no_matches.join_lines()}')
	}

	if config.add != '' {
		now := time.now().unix()
		conn.add_or_update_file(config.add, 1.0, now) or {
		 eprintln('voxide: ${err}') exit(1)
		}
		// all := sql conn.db {
		// 	select from database.File
		// }!
		// println(all)
	}
	dump(config)
}

