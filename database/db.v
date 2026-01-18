module database

import db.sqlite
import orm

pub struct Database {
	path		string	// location of the database file
	// this will be mut for no
	pub mut:
		db		sqlite.DB
}

pub fn open(path string) !Database {
	mut db := sqlite.connect(path)!

	return Database {
		path: path
		db:		db
	}
}

pub fn (mut db Database) close() {
	db.db.close() or {}
}

pub fn (db &Database) create() ! {
	sql db.db {
		create table File
	}!
}

pub fn (db Database) drop() ! {
	sql db.db {
		drop table File
	}!
}

fn (db Database) find_files(path string) ![]File {
	qb := orm.new_query[File](db.db)

	files :=
		qb
			.where('path LIKE ?','%${path}%')!
			.query()!

	return files
}

fn (db Database) find_file(path string) !File {
	qb := orm.new_query[File](db.db)

	file :=
		qb
			.where('path = ?', path)!
			.query()!
			.first()

	return file
}

pub fn (db Database) add_or_update_file(path string, incr Rank, now Epoch) ! {
	qb := orm.new_query[File](db.db)
	file := db.find_matches(path)
	if mut x := file {
		x.sort_with_compare(fn [now] (a &File, b &File) int {
			return sort(a, b, now)
		})
		f := x[0]
		score := f.score + incr
		println(f.score(now))
		println(x)
		qb
			.set('score = ?, last_accessed = ?', score, now)!
			.where('path = ?', f.path)!
			.update()!
	} else {
		f := File {
			path: path
			score: incr
			last_accessed: now
		}
		sql db.db {
			insert f into File
		}!
	}
}


pub fn (db Database) find_matches(path string) ?[]File {
	files := db.find_files(path) or { panic(err) }

	if files.len != 0 {
		mut matches := filter_files_by_name(files)
		return matches
	}
	return none
}
