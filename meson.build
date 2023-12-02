#~ first statement must be a call to project()

project('link-config', ['c', 'vala'],
	version : '0.2', default_options : ['warning_level=3'])

appname = meson.project_name()

#~ 启用 GETTEXT
add_project_arguments(
  '-DGETTEXT_PACKAGE="' + appname + '"', language: 'c')

#~ 依赖组
libadwaita = dependency('libadwaita-1')
gtk4 = dependency('gtk4')
posix = meson.get_compiler('vala').find_library('posix')

#~ 内嵌资源，自动注册资源
gnome = import('gnome')
#~ 第一个参数 id，是 build 下产生的 c/h 文件名
gresource = gnome.compile_resources('res', appname+'.resource.xml')

#~ 编译，并注册参数表
#~ https://mesonbuild.com/Gnome-module.html#gnomecompile_schemas

#~ Function accepts only strings, integers, bools, lists, dictionaries and lists thereof.
message ('---->'+meson.current_source_dir()+'<---->'+appname+'<-----------\n')

executable(appname,
	gresource,
	'link-config.vala',
	dependencies: [libadwaita, gtk4, posix],
	install : true,
#~ 	真的不让把执行文件放到 build 的上层目录
#~ 	install_dir: meson.current_source_dir(),
	)
