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



#	--------▶  2026-06-25 16:27:50 ◀ --------
⭕ git clone git@github.com:eexpress/link-config.git
⭕ cd link-config
⭕ sudo dnf install meson ninja vala glib2-devel libadwaita-devel cmake
⭕ meson setup build
⭕ ninja -C build

