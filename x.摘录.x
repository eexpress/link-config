#	--------▶  2023-11-30 14:31:37 ◀ --------
⭕ meson init --force
Using "link-config" (name of current directory) as project name.
Using "link-config" (project name) as name of executable to build.
Detected source files: link-config.vala
Detected language: vala
Generated meson.build file:

project('link-config', ['c', 'vala'],
  version : '0.1',
  default_options : ['warning_level=3'])

executable('link-config',
           'link-config.vala',
           install : true)



