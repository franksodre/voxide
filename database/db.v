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
	sql data.db {
		delete from File where path == path
	}!
}

pub fn (data Database) exists(path string) !bool {
	p := sql data.db {
		select from File where path == path
	}!.first() // the path should just be unique

	if p.path != ''  {
		return true
	}
	return false
}

pub fn (data Database) select_all() ![]File {
	all := sql data.db {
		select from File
	}!
	return all
}

// SEARCHES
pub fn (data Database) find_files(path string) ![]File {
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
	if data.exists(path)! {
		data.update(path, incr, now)!
	} else {
		data.insert(File{ path: path, score: incr, last_accessed: now })!
		return
	}
}

pub fn (data Database) update(path string, incr Rank, now Epoch) ! {
	// If a value lives in the database, its transformations should live there too.
	// No [select] here
	sql data.db {
		update File set score = score + incr
		where path == path
	}!
}
