// TODO: watch Air anime
module database

import db.sqlite

pub struct Database {
	path string // location of the database file
	// this will be mut for no
pub mut:
	db sqlite.DB
}

// obviously i should use env vars
pub fn open(path string) !Database {
  // should check if database exists and if not create it.
  // not here
	mut db := sqlite.connect(path)!

	return Database{
		path: path
		db:   db
	}
}

pub fn (mut data Database) close() {
	data.db.close() or {}
}

// create table File if it doesn't exists already
@[inline]
pub fn (data &Database) create() ! {
	sql data.db {
		create table File
	}!
}

@[inline]
pub fn (data Database) drop() ! {
	sql data.db {
		drop table File
	}!
}

@[inline]
pub fn (data Database) insert(file File) ! {
	sql data.db {
		insert file into File
	}!
}

@[inline]
pub fn (data Database) delete(path string) ! {
	sql data.db {
		delete from File where path == path
	}!
}

pub fn (data Database) exists(path string) !bool {
	// just for now
	query := path
	p := sql data.db {
		select from File where path == query
	}! // the path should just be unique


	if x := p[0] {
		if x.path != '' {
			return true
		}
	}
	return false
}


@[inline]
pub fn (data Database) select_all() ![]File {
	all := sql data.db {
		select from File
	}!
	return all
}

// SEARCHES
@[inline]
pub fn (data Database) find_files(path string) ![]File {
	pattern := '%' + path + '%'
	files := sql data.db {
		select from File where path like pattern
	}!

	return files
}

// [obsolete]?
@[inline]
pub fn (data Database) find_file(path string) !File {
	// just for now
	query := path
	return sql data.db {
		select from File where path == query
	}![0]
}

pub fn (data Database) add(path string, incr Rank, now Epoch) ! {
	if data.exists(path)! {
		data.update(path, incr, now)!
	} else {
		data.insert(File{ path: path, score: incr, last_accessed: now })!
		return
	}
}

@[inline]
pub fn (data Database) update(path string, incr Rank, now Epoch) ! {
	sql data.db {
		update File set score = score + incr
		where path == path
	}!
}
