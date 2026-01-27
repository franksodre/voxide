module command

pub fn (data Database) find_with_args(path string) ?[]File {
	args := path.split(' ')
	// edge case: this shouldn't be here but in the caller i think
	if args.len == 0 {
		return none
	}
	mut matches := [][]File{}
	for arg in args {
		if x := data.find_matches(arg) {
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
		println(flatten[File](matches))
		return flatten[File](matches)
	} else {
		return none
	}
}

// handle arg
// edge case
// find matches
// edge case
// intersecting matrices
// edge case
// else
