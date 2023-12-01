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

#~ Function accepts only strings, integers, bools, lists, dictionaries and lists thereof.
#~ message (gresource+'<-----------------------\n')

message (appname+'<-----------------------\n')

#~ 编译，并注册参数表
#~ gnome.compile_schemas()

#~ When called, this method will compile the gschemas in the current directory. Note that this is not for installing schemas and is only useful when running the application locally for example during tests.
#~  调用时，此方法将编译当前目录中的gschemas。请注意，这不适用于安装模式，仅在本地运行应用程序时（例如在测试期间）有用。

#~     build_by_default: causes, when set to true, to have this target be built by default, that is, when invoking plain meson compile, the default value is true for all built target types
#~ build_by_default：当设置为true时，导致默认情况下构建该目标，也就是说，当调用普通meson编译时，所有构建的目标类型的默认值都为true

#~     depend_files: files (str, files(), or configure_file()) of schema source XML files that should trigger a re-compile if changed.
#~ dependen_files：架构源XML文件的文件（str、files（）或config_file（）），如果更改，则应触发重新编译。

#~ gnome.compile_schemas(build_by_default: true, depend_files: appname+'.gschema.xml')

#~ install_data(
#~ 	appname+'.gschema.xml',
#~ 	install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
#~ 	)

#~ gsettings = gnome.compile_resources('set-id', appname+'.gschema.xml', install: true,install_dir: "/home/eexpss/.locale/share/glib-2.0/shemas/")
#~ gsettings = gnome.compile_resources('set-id',appname+'.gschema.xml')

executable(appname,
	gresource,
	'link-config.vala',
	dependencies: [libadwaita, gtk4, posix],
	install : true,
	)
