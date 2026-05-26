module main

import command  { run_query, run_remove, run_add }
import cli
import os

fn main() {
	os.mkdir_all(os.dir(command.db_path)) or {
	  eprintln(err)
	  exit(1)
	}
	mut app := cli.Command{
		name: 'voxide'
		description: "Better cd command based on rust's zoxide."
	}

	app.add_command(cli.Command{
		name: 'query'
		description: "Search for matches in the database."
		execute: run_query
	})

	app.add_command(cli.Command{
		name: 'add'
		description: "Adds a new path in the database."
		execute: run_add
	})

	app.add_command(cli.Command{
		name: 'remove'
		description: "Remove a path from the database."
		execute: run_remove
	})

	app.setup()
	app.parse(os.args)

}
