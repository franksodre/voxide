#!/usr/bin/env -S v run

import build
import os

const app_name = "voxide"
const wd = os.getwd()
const resolved_path := os.abs_path(wd)

mut context := build.context(
  default: 'run'
)

context.task(
  name:   'build'
  run:    |self| system('v . -o bin/${app_name}')
)

context.task(
  name: 'symlink'
  run: || system('ln -s ${resolved_path} ${os.home_dir()}/.local/bin/${app_name}')
)

context.run()
