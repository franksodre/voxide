module command

pub struct Show implements Run {}

pub fn (cmd Show) run() ! {
	println("Showing...")
}

