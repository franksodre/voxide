module command

pub struct Show {}

pub fn (cmd Show) run() ! {
	println("Showing...")
}

