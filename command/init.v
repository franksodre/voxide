module command

import os
import cli

struct Init {
  input string
}

fn fish_expand() string {
  return 'if status is-interactive
# 1. The Navigation Command (Silent, letting voxide handle errors)
function vx
    if test (count $argv) -gt 0; and test "$argv[1]" = "add"; or test "$argv[1]" = "remove"
	command voxide $argv
    else
	set -l target (command voxide $argv)
	# Only attempt to cd if target is not empty
	if test -n "$target"
	    cd "$target"
	end
    end
end

# 2. The Background Indexer
function _vx_auto_index
    if test "$PWD" != "$__vx_last_dir"
	set -g __vx_last_dir "$PWD"
	command voxide add "$PWD" >/dev/null 2>&1 &
    end
end

# 3. The Event Hook (Clean and Theme-friendly)
set -g __vx_last_dir $PWD
function _vx_event_handler --on-event fish_postexec
    _vx_auto_index
end
end
  '
}

fn new_init() !&Init {
  if os.args.len != 3 {
    eprintln("voxide: You must provide an argument to init. try 'zsh' or 'fish'.")
    exit(1)
  }
  return &Init{
    input: os.args[2]
  }
}

fn (init Init) init() string {
  sh := init.input

  match sh {
    "fish" {
      return fish_expand()
    }

    "frank" {
      return "you're amazing!"
    }
    else { return "not yet implemented." }
  }
}

pub fn run_init(cmd cli.Command) ! {
  init := new_init()!
  println(init.init())
}
