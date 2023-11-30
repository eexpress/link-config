project('link-config', ['c', 'vala'],
  version : '0.1',
  default_options : ['warning_level=3'])

libadwaita = dependency('libadwaita-1')
gtk4 = dependency('gtk4')
posix = meson.get_compiler('vala').find_library('posix')

gnome = import('gnome')
gresource = gnome.compile_resources('res-id',
  'res.github.xml',
)

executable('link-config',
			gresource,
           'link-config.vala',
           dependencies: [libadwaita, gtk4, posix],
           install : true)
