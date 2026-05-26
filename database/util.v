module database
import os

pub const k_second = Epoch(1)
pub const k_minutes = Epoch(60 * k_second)

pub const k_hour = Epoch(60 * k_minutes)
pub const k_day = Epoch(24 * k_hour)
pub const k_week = Epoch(7 * k_day)

// receiver `e`
// @param 	`n`
// subtracts e with n and clamp to zero with the result of the sub it's negative
pub fn (e Epoch) sub_clamp_zero(n Epoch) Epoch {
	sub := e - n
	return if sub < 0 { 0 } else { sub }
}

// i don't know how to name this thing and where to put it
fn filter_files_by_name(files []File) []File {
	mut matches := []File{}

	// changing some stuff just to test on directories.
	for file in files {
		file_name := file.path.split('/').filter(|x| x != '').last()
		if os.file_name(file.path) == file_name {
			matches << file
		}
	}

	return matches
}
//
fn sort(a &File, b &File, now Epoch) int {
	score_a := a.score(now)
	score_b := b.score(now)
	if score_a < score_b {
		return 1
	}
	if score_a > score_b {
		return -1
	}
	return 0
}

fn query_path(query string) !string {
	if query == '' { /* show_help() */ panic('voxide: you must provide a query') }
	qr := os.expand_tilde_to_home(query)
	dir := if os.is_abs_path(qr) {
		 os.abs_path(qr)
	 } else {
		 qr
	 }
	 // os.chdir(dir) or { panic('voxide: unable to go into $dir') }
	 return dir
}
