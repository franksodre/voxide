module command

import os
import time
import database { Database, open }

const path_separator = '/'
const cwd = os.getwd()

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

fn (o Query) best_match(queries []string, now i64) ![]string {
	mut query := o.conn.find_files(queries[0])!
	for q in queries[1..] {
		query = intersect(query, o.conn.find_files(q)!)
	}
	if query.len == 0 {
		eprintln("voxide: no match found")
		exit(1)
	}
  // TODO: queries to strict paths may not depend on the score for better results.
	query.sort_files_by_score(now)
	return query.filter(it.path != cwd).map(it.path)
}

fn find_in_cwd(query string) ?string {
	entries := os.ls(cwd) or { [] }

	for entry in entries {
		dir := os.join_path_single(cwd, entry)
		if os.is_dir(dir) && entry == query {
			return dir
		}
	}

	return none
}

pub fn (o Query) query() !string {
	args := o.args
	now := time.now().unix()

	if args.len == 0 {
		eprintln("voxide: A path must be provided [you don't go straight to home yet].")
		exit(1)
	}


	if args[0].contains(path_separator) {
		if p := path_exists(args[0]) {
			return os.abs_path(p)
		}
		o.best_match(args, now)!.first()
	}

	if p := find_in_cwd(args[0]) {
		return p
	}

	paths := o.best_match(args, now)!
	for path in paths {
		if dir_basename(path).to_lower().starts_with(args[0]) {
			return path
		}
		// should return an error?
	}

	return paths.first()
}

pub fn (cmd Query) run() ! {
	query := new_query()!
	println(query.query()!)
}
