//~ valac --pkg libadwaita-1 --pkg gtk4 --pkg posix "%f"
//~ ⭕ cd build/; ninja
//~ 只有 meson 调用的 gnome.compile_resources 能自动编译 xml，并且注册好。

using Gtk;

//~ TODO 搞定 gettext，编译通不过
//~ const string GETTEXT_PACKAGE = "...";
//~ extern const string GETTEXT_PACKAGE;
//~ [CCode(cname="GETTEXT_PACKAGE")] extern const string GETTEXT_PACKAGE;
//~ [CCode(cname="GETTEXT_PACKAGE")] extern GResource *res_get_resource ();
//~ 	Gsettings 需要xml文件，需要注册，并且在系统目录留下文件。比如 /usr/share/glib-2.0/schemas/。不如直接rc文件了。
//~ 	gsetting 设置上一次工作目录

const string appID = "io.github.eexpress.link.config";
const string appTitle = "Link Config";

List<string> pluslist;
Adw.ActionRow row;
ListBox listbox;
Label msg;
ApplicationWindow window;

string Git_Ls;
string HomeDir;
string WorkDir;
string Flastpath;

//~ --------------------------------------------------------------------
int main(string[] args) {
	var app = new Adw.Application(appID, ApplicationFlags.DEFAULT_FLAGS);
//~ 	var ss = new GLib.Settings(appID);	// GLib-GIO-ERROR **: 23:07:43.191: Settings schema 'io.github.eexpress.link.config' is not installed
//~ 	print("lastpath = %s\n", ss.get_string("lastpath"));
	app.activate.connect(onAppActivate);
	return app.run(args);
}
//~ --------------------------------------------------------------------
void onAppActivate(GLib.Application self) {	// 为什么这里必须是 GLib 的 Application
//~ 窗口
	window = new ApplicationWindow(self as Gtk.Application);
	window.title = appTitle;
	window.set_default_size(440, 440);
	window.resizable = false;
//~ 底盒
	var box = new Box(Orientation.VERTICAL, 5);
	box.set_margin_start(10); box.set_margin_end(10);
	box.set_margin_top(10); box.set_margin_bottom(10);
//~ 列表
	listbox = new ListBox();
//~ 列表的占位控件
	var x = new Label("");
//~ 	x.set_markup("<span foreground=\"grey\" size=\"1000%\">空</span>");
	x.set_markup(_("<span foreground=\"grey\" size=\"300%\">拖放文件目录到此</span>"));
	listbox.set_placeholder(x);
//~ 列表的拖放
	var string_drop = new DropTarget(GLib.Type.STRING, Gdk.DragAction.COPY);
	listbox.add_controller(string_drop);
	string_drop.drop.connect((self, value, x, y) => {	// value.type_name()
		string s = value.get_string();
		if(checkfile(s)) addfile(File.parse_name(s));
		return true;
	  });
//~ 标题
	row = new Adw.ActionRow();
	row.title=_("<b>配置备份列表</b>");
	string tip = _("""图例说明
	源配置：🔗 正常 💔 坏链接 🅕 非链接 ␀ 无文件
	git管理：☂️ 是 ✖️ 否

拖放目录或者文件到下面的列表，均可建立备份""");
	row.set_tooltip_text(tip);
//~ 信息条
	msg = new Label("");
	msg.halign = Align.START;
	msg.set_markup("<b>%s</b>. Ver 0.21.".printf(appID));
//~ 按键组
	var butbox = new Box(Orientation.HORIZONTAL, 5);
	string[] btarr = {	// vala的二维数组是废品
	// 图标，标签，提示
		_("document-new-symbolic|添加文件|移动源文件过来，在源位置建立链接"),
		_("folder-new-symbolic|添加目录|移动源目录过来，在源位置建立链接"),
		_("edit-delete-symbolic|取消备份|删除源链接，移动备份文件到源位置"),
		_("insert-link|全部恢复|在源位置强行重新建立全部链接"),
		_("go-home-symbolic|切换目录|切换当前工作目录")
	};
	for (var i = 0; i < btarr.length; i++){
		string[] s = btarr[i].split("|");
		var b = new Adw.ButtonContent();
		b.icon_name = s[0];
		b.label = s[1];
		b.set_tooltip_text(s[2]);
		var bt = new Button();
		bt.set_child(b);
		var index = i;	// 不保存， lambda 输入就固定是4了。
		bt.clicked.connect (()=>{click(index);});
		if(index == btarr.length-1){
			row.add_suffix(bt);
		} else butbox.append(bt);
	}
//~ 标题加一个内嵌的图标
	var img = new Image.from_resource ("/io.github.eexpress/img/github.png");
	img.set_pixel_size(48);
	row.add_suffix(img);
// 获取执行文件路径，并切换工作目录。
	HomeDir = Environment.get_home_dir();
	Git_Ls = exec("git ls-files");
	try{
		WorkDir = Path.get_dirname(FileUtils.read_link("/proc/self/exe"));
	} catch (Error e) {error ("%s", e.message);}
//~ 	读取最后的目录
	Flastpath = HomeDir+"/.config/"+appID+"/lastpath";
//~ 	Flastpath = Environment.get_user_config_dir()+"/"+appID+"/lastpath";
//~ 	print(Environment.get_user_data_dir()+"\n");
	string contents;
	try {
		if(FileUtils.test(Flastpath, FileTest.EXISTS)){
			if (FileUtils.get_contents (Flastpath, out contents)){
				if(FileUtils.test(contents, FileTest.IS_DIR)){
					WorkDir=contents;
				}
			}
		} else {
//~ 			Posix.mkdir(HomeDir+"/.config/"+appID+"/", 0755);
			DirUtils.create_with_parents (HomeDir+"/.config/"+appID+"/", 0775);
		}
	} catch (Error e) {error ("%s", e.message);}

	refreshall(WorkDir);
//~ 窗口布局和呈现
	window.child = box;
	box.append(row);
	box.append(listbox);
	box.append(butbox);
	box.append(msg);
	window.present ();
}
//~ --------------------------------------------------------------------
void click(int i){
	switch(i){
		case 0:
			on_add_clicked(true); break;
		case 1:
			on_add_clicked(false); break;
		case 2:
			on_rm_clicked(); break;
		case 3:
			on_restore_clicked(); break;
		case 4:
			on_chdir_clicked(); break;
	}
}
//~ --------------------------------------------------------------------
void on_rm_clicked(){
	unowned ListBoxRow? row = listbox.get_selected_row();
	if(row == null) return;
	unowned List<string> lst = pluslist.nth (row.get_index());
	if (rmfile(lst.data, true)){	// 正确删除备份
		listbox.remove(row);
		pluslist.remove_link (lst);
	};
}
//~ --------------------------------------------------------------------
void on_restore_clicked(){
	pluslist.foreach ((plusfile) => {
		rmfile(plusfile, false);
	});
	msg.set_markup(_("已经全部恢复配置的链接。"));
}
//~ --------------------------------------------------------------------
async void on_chdir_clicked () {
	File ? f = yield filedialog(_("选择需要切换的目录"), false);
	if (f == null) return;
	refreshall(f.get_parse_name());
//~ 	保存最后的目录
	try {
		FileUtils.set_contents(Flastpath, f.get_parse_name(), -1);
	} catch (Error e) {error ("%s", e.message);}
}
//~ --------------------------------------------------------------------
void refreshall(string s){
	WorkDir = s;
	Posix.chdir(WorkDir);	//切换工作目录
	Git_Ls = exec("git ls-files");
	refreshListBox();		//刷新
	string p = WorkDir.replace(HomeDir,"~");
	row.subtitle=_("当前工作目录：")+"<span foreground=\"blue\"><b>%s</b></span>".printf(p);
	window.set_size_request(100,100);
	window.queue_resize();
}
//~ --------------------------------------------------------------------
async void on_add_clicked (bool Select_file) {
	File ? f = yield filedialog(_("选择需要备份的配置文件或目录"), Select_file);
	if (f == null) return;
	if(checkfile(f.get_parse_name())) addfile(f);
}
//~ --------------------------------------------------------------------
async File filedialog(string Title, bool Select_file){
	File ? f = null;
	var dialog = new Gtk.FileDialog ();	// 显示隐藏文件，只能按 Ctrl-h
	dialog.title = Title;
	try {
		if(Select_file){
			f = yield dialog.open(null, null);	// yield 必须在 async 内部
		} else {
			f = yield dialog.select_folder(null, null);
		}
// 必须catch一堆，如果直接退出异步函数，会Dismissed by user 追踪与中断点陷阱（核心已转储）
	} catch (IOError.CANCELLED e) {
	} catch (Gtk.DialogError.CANCELLED e) {
	} catch (Gtk.DialogError.DISMISSED e) {
	} catch (Error e) {error ("%s", e.message);}
	return f;
}
//~ --------------------------------------------------------------------
bool checkfile(string fn){
	if(!FileUtils.test(fn, FileTest.EXISTS)){msg.set_markup(_("⚠️ 文件不存在。")); return false;}
	if(FileUtils.test(fn, FileTest.IS_SYMLINK)){msg.set_markup(_("⚠️ 不能备份链接文件。")); return false;}
	if (! fn.contains(HomeDir+"/."))
		{ msg.set_markup(_("⚠️ 只能备份家目录下的隐藏目录或文件。")); return false; }
	return true;
}
//~ --------------------------------------------------------------------
bool addfile(File Fconfig){	// 配置文件句柄
	string src = Fconfig.get_parse_name();	// 配置文件
	string plusfile = formatFilename(src, true);	// 带+号文件名
	string dst = WorkDir+"/"+plusfile;	// 备份文件
	File Fbackup = File.parse_name(dst);		// 备份文件句柄
//~ 	print("----\nmv %s %s; ln -sf %s %s\n", src, dst, dst, src);
	try {
		if (Fconfig.move(Fbackup,FileCopyFlags.NONE, null, null)){
			if(Fconfig.make_symbolic_link(dst,null)){	// 注意方向：File是链接，string才是源文件。
				pluslist.append(plusfile); appendListBox(plusfile);
				exec("ls -l "+src); return true;
			}
		};
	} catch (Error e) {error ("%s", e.message);}
	return false;
}
//~ --------------------------------------------------------------------
bool rmfile(string plusfile, bool moveORrestroe){	// 带+号文件名
	string dst = WorkDir+"/"+plusfile;	// 备份文件
	string src = formatFilename(plusfile, false);	// 配置文件
	File Fbackup = File.parse_name(dst);	// 备份文件句柄
	File Fconfig = File.parse_name(src);		// 配置文件句柄
	try {
		if(Fconfig.query_exists()) Fconfig.delete();
	} catch (Error e) {error ("%s", e.message);}
	try {
		if(moveORrestroe){
//~ 	print("----\nrm %s; mv %s %s\n", src, dst, src);
			if(Fbackup.move(Fconfig,FileCopyFlags.NONE, null, null)){
				exec("ls -l "+src); return true;
			}
		}else{
//~ 	print("----\nrm %s; ln -sf %s %s\n", src, src, dst);
			if(Fconfig.make_symbolic_link(dst,null)){
				exec("ls -l "+src); return true;
			}
		}
	} catch (Error e) {error ("%s", e.message);}
	return false;
}
//~ --------------------------------------------------------------------
string exec(string cmd){
	string stdout, stderr; int status;
	try{	//~ 简化版本的 spawn_sync。
		Process.spawn_command_line_sync (cmd, out stdout, out stderr, out status);
	} catch (Error e) { error ("%s", e.message);}
	if(status!=0){ print(stderr); }
	return stdout;
}
//~ --------------------------------------------------------------------
void refreshListBox(){	// remove_all 能工作后，可能需要多次调用。
//~ 	listbox.remove_all();	// not available in gtk4 4.10.5. Use gtk4 >= 4.12
	listbox_remove_all();
	listplusfile();
	pluslist.foreach ((i) => {		// 警告：不兼容的指针类型间转换
		appendListBox(i);
	});
}
//~ --------------------------------------------------------------------
void appendListBox(string fn){
	var prefix = "";
	var lbl = new Label("");
	lbl.xalign = (float)0;	// 左对齐。默认居中？
	prefix += checklink(fn);	// 正确的链接
	prefix += Git_Ls.contains(fn) ?"☂️️️":"✖️️️️";	// 是否在 git 仓库
	string s = formatFilename(fn, false);
	try {
//~ 家目录路径，转化成~的缩写，缩短显示。
		Regex ex = new Regex("^"+HomeDir);
		s = ex.replace(s, s.length, 0, "~");
//~ 		s = s.replace(HomeDir, "~");	// max_tokens 失效，不安全了。
//~ 目录的最后一段，文件的倒数第二段目录，加粗标记
		string[] a = s.split("/",0);
		if(FileUtils.test(fn, FileTest.IS_DIR)){
			a[a.length-1] = "<b>"+a[a.length-1]+"</b> 📂";
		}else{
			if(a.length>2) a[a.length-2] = "<b>"+a[a.length-2]+"</b>";
			else a[a.length-1] = "<b>"+a[a.length-1]+"</b>";
		}
		s = string.joinv("/", a);		//join 乱码！！
	} catch (Error e) {error ("%s", e.message);}
	lbl.set_markup(prefix+"\t"+s);
	listbox.insert(lbl, -1);
}
//~ --------------------------------------------------------------------
string checklink(string plusfile){	// 带+号的本地文件
//~ 	本地文件转化成源文件
	string r = formatFilename(plusfile, false);
	try {
		if(!FileUtils.test(r, FileTest.EXISTS)) return "␀";	//源配置文件不存在
		if(!FileUtils.test(r, FileTest.IS_SYMLINK)) return "🅕";	//源配置文件必须是链接
		if(FileUtils.read_link(r) != WorkDir+"/"+plusfile) return "💔";	// 源文件链接 == 本地文件
	} catch (Error e) {error ("%s", e.message);}
	return "🔗";
}
//~ --------------------------------------------------------------------
void listplusfile(){
//~ 	找出当前目录+号开头的文件，建立列表。
	pluslist = new List<string> ();
	try {
		var d  = GLib.Dir.open(WorkDir, 0);
		string ? fn = null;	// 可空字符串
		while ((fn = d.read_name()) != null) {
			if(fn[0] == '+') { pluslist.append (fn); }
		}
	} catch (Error e) {error ("%s", e.message);}
	pluslist.sort(strcmp);	// strcmp 什么鬼？
}
//~ --------------------------------------------------------------------
string formatFilename(string str, bool change2plus){
//~ 	change2plus 方向，true 为变+号格式，false 为恢复正常路径格式。
	Regex ex;
	string r = str;	// 不要直接修改传入参数
	if(change2plus){	// "s|^${HOME}/.|+|; s|/|+|g; s|\ |=|g"
		try{
			ex = new Regex("^"+HomeDir+"/.");
			r = ex.replace(r, r.length, 0, "+");
			ex = new Regex("^~/."); r = ex.replace(r, r.length, 0, "+");
			ex = new Regex("/"); r = ex.replace(r, r.length, 0, "+");
			ex = new Regex("\\ "); r = ex.replace(r, r.length, 0, "=");
		}catch (Error e) {error ("%s", e.message);}
	} else {			// 's|^+|~/.|; s|+|/|g; s|=| |g'
		try{
			ex = new Regex("^\\+"); r = ex.replace(r, r.length, 0, HomeDir+"/.");
			ex = new Regex("\\+"); r = ex.replace(r, r.length, 0, "/");
			ex = new Regex("="); r = ex.replace(r, r.length, 0, " ");
		}catch (Error e) {error ("%s", e.message);}
	}
	return r;
}
//~ --------------------------------------------------------------------
void listbox_remove_all(){
	unowned ListBoxRow? row = listbox.get_row_at_index(0);
	while(row != null){
		listbox.remove(row);
		row = listbox.get_row_at_index(0);
	}
}
//~ --------------------------------------------------------------------
