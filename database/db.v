// TODO: watch Air anime
module database

import db.sqlite
import orm
import arrays { flatten }
import time

pub struct Database {
	path string // location of the database file
	// this will be mut for no
pub mut:
	db sqlite.DB
}

// obviously i should use env vars
pub fn open(path string) !Database {
	mut db := sqlite.connect(path)!

	return Database{
		path: path
		db:   db
	}
}

pub fn (mut data Database) close() {
	data.db.close() or {}
}

pub fn (data &Database) create() ! {
	sql data.db {
		create table File
	}!
}

pub fn (data Database) drop() ! {
	sql data.db {
		drop table File
	}!
}

pub fn (data Database) insert(file File) ! {
	sql data.db {
		insert file into File
	}!
}

pub fn (data Database) delete(path string) ! {
	mut qb := orm.new_query[File](data.db)
	qb.where('path = ?', path)!.delete()!
}

pub fn (data Database) select_all() ![]File {
	all := sql data.db {
		select from File
	}!
	return all
}

// SEARCHES
fn (data Database) find_files(path string) ![]File {
	qb := orm.new_query[File](data.db)

	files := qb
		.where('path LIKE ?', '%${path}%')!
		.query()!

	return files
}

fn (data Database) find_file(path string) !File {
	qb := orm.new_query[File](data.db)

	file := qb
		.where('path = ?', path)!
		.query()!
		.first()

	return file
}

// check if exists
// yes: update and return
// no: create and return
pub fn (data Database) add(path string, incr Rank, now Epoch) ! {
	mut file := data.find_with_args(path) or {
		eprintln('malformed path, i do think its the right err')
		return
	}
	if file.len == 0 {
		data.insert(File{ path: path, score: incr, last_accessed: now })!
		return
	}
}

pub fn (data Database) update(path string, incr Rank, now Epoch) ! {
	mut file := data.find_with_args(path) or {
		eprintln('malformed path, i do think its the right err')
		return
	}
	qb := orm.new_query[File](data.db)
	file.sort_files_by_score(now)
	best_match := file.first()
	new_score := best_match.score + incr

	qb
		.set('score = ?, last_accessed = ?', new_score, now)!
		.where('path = ?', best_match.path)!
		.update()!
}

pub fn (data Database) query(path string) ! {
	// check like an exact matches
	mut file := data.find_with_args(path) or {
		eprintln('malformed path, i do think its the right err')
		return
	}
	now := time.now().unix()
	// // it's basically checking the same thing above - absurd
	// if file.len == 0 {
	// 	data.add(path, 1.0, now)!
	// 	return
	// }
	file.sort_files_by_score(now)
	best_match := file.first()
	println(best_match)
	println("${best_match.path}/") // hack. fix later
}

pub fn (db Database) find_matches(path string) ?[]File {
	files := db.find_files(path) or { panic(err) }

	if files.len != 0 {
		mut matches := filter_files_by_name(files)
		return matches
	}
	return none
}

pub fn (db Database) find_with_args(path string) ?[]File {
	args := path.split(' ')
	if args.len == 0 {
		return none
	}
	mut matches := [][]File{}
	for arg in args {
		if x := db.find_matches(arg) {
			matches << x
		} else {
			none
		}
	}
	mut res := []File{}
	// this is ugly, i try something better later, am just trying get the job done
	// TODO: some issues here, handle later
	if !path.contains_u8(`/`) && args.len > 1 {
		for x in 1 .. matches.len {
			res = intersect(matches[0], matches[x])
		}
		return res
	} else if args.len == 1 {
		return flatten[File](matches)
	} else {
		return none
	}
}
