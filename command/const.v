module command
import os

pub const home_dir = os.home_dir()
pub const db_path = os.join_path(os.home_dir(), '.local', 'share', 'voxide', 'voxide.db')
