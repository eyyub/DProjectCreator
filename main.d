module main;

import gtk.Main;

import DProjectCreator;
pragma(lib, "GtkD.lib");

void main(string[] args)
{
	Main.init(args);
	auto program = new DProjectCreator;
	scope(exit) clear(program);
	Main.run();
}