module DProjectCreator;

import std.path;
import std.file;
import std.stdio;
import std.array;
import gtk.MainWindow;
import gtk.Frame;
import gtk.HBox;
import gtk.VBox;
import gtk.Button;
import gtk.CheckButton;
import gtk.Alignment;
import gtk.Label;
import gtk.Entry;
import gtk.FileSelection;
import gtk.MessageDialog;
import gtk.Main;


final class DProjectCreator : MainWindow
{
	private
	{
		Frame _frame;
		Button _choosePath;
		Button _create; 
		VBox _vbox;
		Label _project;
		Entry _name;
		Entry _path;
		Entry _others;
		FileSelection _dialog;
		CheckButton[string] _lib;
		
		void onChoosePath(Button b)
		{
			_dialog.run();
			if(_dialog.getFilename().isDir)
				_path.setText(_dialog.getFilename());
			else
			{
				auto errordia = new MessageDialog(_dialog, DialogFlags.MODAL, MessageType.ERROR, ButtonsType.OK, "Please select a directory, not a file");
				errordia.run();
				errordia.destroy();
				_path.setText("");
			}
			_dialog.hide();
		}
		void onCreateProject(Button b)
		{
			if(!_path.getText() ~ "\\" ~ _name.getText().exists)
				mkdir(_path.getText() ~ "\\" ~ _name.getText());
			
			File main = File(_path.getText() ~ "\\" ~ _name.getText() ~ "\\" ~ "main.d", "w");
			main.writeln("module main;\n");
			main.writeln("import std.stdio;\n");
			
			foreach(key; _lib.byKey())
			{
				if(_lib[key].getActive())
					main.writeln("pragma(lib, " ~ "\"" ~ key ~ ".lib\");");
			}
			if(!_others.getText().empty)
			{
				string[] words = _others.getText().split(",");
				foreach(word; words)
				{
					main.writeln("pragma(lib, " ~ "\"" ~ word ~ ".lib\");");
				}
			}
			
			main.writeln("\nvoid main()\n{\n	\n}");
			auto success = new MessageDialog(this, DialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, "Success !");
			success.run();
			success.destroy();
			Main.exit(false);
		}
		HBox configureProjectsName()
		{
			HBox h = new HBox(true, 0);
			h.packStart(_project, false, false, 0);
			h.packStart(_name, false, false, 0);
			return h;
		}
		HBox configurePath()
		{
			HBox h = new HBox(true, 0);
			h.packStart(_choosePath, false, false, 0);
			h.packStart(_path, false, false, 0);
			return h;
		}
		HBox configureOthers()
		{
			HBox h = new HBox(true, 0);
			h.packStart(new Label("Others libs"), false, false, 0);
			h.packStart(_others, false, false, 0);
			return h;
		}
		VBox configureImports()
		{			
			VBox imports = new VBox(true, 0);
			imports.packStart(configureDerelict(), false, false, 0);
			
			//GtkD
			HBox gtkD_HBox = new HBox(true, 0);
			gtkD_HBox.packStart(new CheckButton("GtkD"), false, false, 0);
			imports.packStart(gtkD_HBox, false, false, 0);
			
			//Others
			imports.packStart(configureOthers(), false, false, 0);
			
			return imports;
		}
		Frame configureDerelict()
		{
			configureDerelictLib();
			Frame derelictFrame = new Frame("Derelict");
			VBox vbox = new VBox(true, 0);
			HBox hboxs[7];
			foreach(ref hbox; hboxs)
			{
				hbox = new HBox(true, 0);
			}
			uint idHBox;
			uint idCheckButton;
			foreach(key; _lib.byValue())
			{
				hboxs[idHBox].packStart(key, false, false, 0);
				if(idCheckButton == 3)
				{
					vbox.packStart(hboxs[idHBox], false, false, 0);
					++idHBox;
					idCheckButton = 0;
				}
				++idCheckButton;
			}
			derelictFrame.add(vbox);
			
			return derelictFrame;	
		}
		void configureDerelictLib()
		{
			_lib["DerelictUtil"] = new CheckButton("Util");
			_lib["DerelictUtil"].setActive(true);
			
			_lib["DerelictAL"] = new CheckButton("OpenAL");
			_lib["DerelictAllegro"] = new CheckButton("Allegro");
			_lib["DerelictSDL"] = new CheckButton("SDL");
			_lib["DerelictSDLImage"] = new CheckButton("SDL Image");
			_lib["DerelictSDLMixer"] = new CheckButton("SDL Mixer");
			_lib["DerelictSDLNet"] = new CheckButton("SDL Net");
			_lib["DerelictSDLTTF"] = new CheckButton("SDL TTF");
			_lib["DerelictGL"] = new CheckButton("OpenGL");
			_lib["DerelictGLU"] = new CheckButton("GLU");
			_lib["DerelictIL"] = new CheckButton("DevIL");
			_lib["DerelictODE"] = new CheckButton("ODE");
			_lib["DerelictOGG"] = new CheckButton("OGG");
			_lib["DerelictPA"] = new CheckButton("PA");
			_lib["DerelictFT"] = new CheckButton("FreeType");
			_lib["DerelictSFMLAudio"] = new CheckButton("SFML Audio");
			_lib["DerelictSFMLGraphics"] = new CheckButton("SFML Graphics");
			_lib["DerelictSFMLNetwork"] = new CheckButton("SFML Network");
			_lib["DerelictSFMLWindow"] = new CheckButton("SFML Window");
		}
	}
	public
	{
		this()
		{
			super("DProjectCreator");
			_vbox = new VBox(false, 0);
			resize(200, 200);
			_project = new Label("D Project's name : ");
			_path = new Entry;
			_name = new Entry;
			_others = new Entry;
			
			_choosePath = new Button("Directory");
			_choosePath.addOnClicked(&onChoosePath);
			
			_create = new Button("Create a project");
			_create.addOnClicked(&onCreateProject);
			
			_dialog = new FileSelection("Select a directory");
			
			_frame = new Frame("Import(s)");
			_frame.add(configureImports());
			
			_vbox.packStart(configureProjectsName(), false, false, 0);
			_vbox.packStart(configurePath(), false, false, 0);
			_vbox.packStart(_frame, false, false, 0);
			_vbox.packStart(_create, false, false, 0);
			
			add(_vbox);
			
			showAll();
		}
		~this()
		{
			clear(_project);
			clear(_path);
			clear(_name);
			clear(_others);
			clear(_choosePath);
			clear(_create);
			clear(_dialog);
			clear(_frame);
			clear(_dialog);
			clear(_lib);
			clear(_vbox);		
		}
	}
}