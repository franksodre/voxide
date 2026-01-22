module database

pub type Rank = f64
pub type Epoch = u64

@[table: 'File']
pub struct File {
pub mut:
	path					string	@[sql: 'path']
	score					f64
	last_accessed	u64
}

pub fn new_file(path string, score f64, last_accessed u64) &File {
	file := &File{
		path: path
		score: score
		last_accessed: last_accessed
	}
	return file
}

// implementations

pub fn (f File) score(now Epoch) Rank {
	mut duration := now.sub_clamp_zero(f.last_accessed)

	match true {
		duration < k_hour { return f.score * 4.0 }
		duration < k_day	{ return f.score * 2.0 }
		duration < k_week { return f.score * 0.5 }
		else { return f.score * .25 }
	}
}

pub fn (mut f []File) sort_files_by_score(t Epoch) {
	f.sort_with_compare(fn [t] (a &File, b &File) int {
		return sort(a, b, t)
	})
}

