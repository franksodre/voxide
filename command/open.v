module command

import cli
import os
import time
import database { Database, open }

const path_separator = '/'
const cwd = os.getwd()

struct Query {
	input []string
mut:
	conn Database
}

// am not sure about this
fn new_query() !&Query {
	input := os.args[2..]
	mut db := open(db_path) or {
		eprintln('voxide: Failed to open database, err: ${err}')
		exit(1)
	}

	db.create()!

	return &Query{
		input: input
		conn:  db
	}
}

// path_exists already does something like it

// Filters paths in the database, checking if they exist in the filesystem
// excluding the cwd in the search.
fn (query Query) filter_path(paths []string) []string {
	p := paths.filter(os.exists(it) && it != cwd).map(it)
	if p.len == 0 {
		eprintln('voxide: no match found')
		exit(1)
	}
	return p
}

fn (query Query) best_match(queries []string, now i64) ![]string {
	// find paths
	mut matches := query.conn.find_files(queries[0])!

	// intersect queries
	for q in queries[1..] {
		matches = intersect(matches, query.conn.find_files(q)!)
	}
	// check if it didn't find anything.
	if matches.len == 0 {
		eprintln('voxide: no match found')
		exit(1)
	}
	// TODO: queries to strict paths may not depend on the score for better results.
	// sort by score
	matches.sort_files_by_score(now)
	rest := matches.filter(it.path != cwd).map(it.path)

	if rest.len == 0 {
		eprintln('voxide: you are already at the only match.')
		exit(0)
	}
	return rest
}

fn find_in_cwd(query string) ?string {
	entries := os.ls(cwd) or { [] }

	// path resolution
	for entry in entries {
		dir := os.join_path_single(cwd, entry)
		if os.is_dir(dir) && entry == query {
			return dir
		}
	}

	return none
}

pub fn (query Query) query() !string {
	input := query.input
	now := time.now().unix()

	if input.len == 0 {
		return os.home_dir()
	}

	if p := find_in_cwd(input[0]) {
		return p
	}

	if input[0].contains(path_separator) {
		// println("print 1")
		if p := path_exists(input[0]) {
			return os.abs_path(p)
		}
		query.best_match(input, now)!.first()
	}

	paths := query.filter_path(query.best_match(input, now)!)
	for path in paths {
		if dir_basename(path).to_lower().contains(input.last()) { // easy fix -> input.first to input.last()
			return path
		}
	}
	eprintln('voxide: you are already in the only match.')
	exit(1)
}

pub fn run_query(cmd cli.Command) ! {
	query := new_query()!
	println(query.query()!)
}
