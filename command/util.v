module command

import os

import database { File }

pub fn intersect(a []File, b []File) []File {
	mut b_set := map[string]bool{}

	for x in b {
		b_set[x.path] = true
	}

	return a.filter(it.path in b_set)
}

// returns the path if exists
// TODO: find a better name for this function
pub fn path_exists(path string) !string {
	if os.exists(path) && os.is_dir(path) {
		return path
	}
	return error("voxide: path not found")
}

pub fn dir_basename(path string) string {
	if os.is_dir(path) {
		return path.split(path_separator).last()
	}
	return ""
}

// currenty i have 3 options
// smash those 3 into 2
// get the current directory dir like: vx dir it's the same and should be expand to /home/franksodre/dir
// which is the same thing as doing: vx /home/fraknsodre/dir even if it's not in the wd
//
