import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import haxe.io.Path;
import haxe.zip.Reader;

class Project
{
	public var projectName:String;
	public var projectClass:String;
	public var width:String;
	public var height:String;
	public var frameRate:String;

	private function new()
	{
		// defaults
		projectName  = "";
        projectClass = "Main";
        width        = "640";
        height       = "480";
        frameRate    = "60";
	}

	public static function create(args:Array<String>)
	{
        var slash:String = "";

		var path = args.pop();
		var project = new Project();

		// parse command line arguments
		var length = args.length;
		var i = 0;
		while (i < length)
		{
			switch (args[i])
			{
				case '-s':
					i += 1;
					var size = args[i].split('x');
					project.width = size[0];
					project.height = size[1];

				case '-r':
					i += 1;
					project.frameRate = args[i];

				case '-c':
					project.projectClass = args[i].charAt(0).toUpperCase() + args[i].substr(1).toLowerCase();

				default:
					var name = args[i];
					project.projectName = name;
					path += name + '/';
			}
			i += 1;
		}

		project.make(path);
	}

	private function make(path:String)
	{
		path = createDirectory(path);

		if (FileSystem.isDirectory(path))
		{
			// read the template zip file
			var templateZip = File.read("template.zip", true);
			var entries = Reader.readZip(templateZip);
			templateZip.close();

			// unzip the file
			for (entry in entries)
			{
				var filename:String = entry.fileName;

				// check if it's a folder
				if (StringTools.endsWith(filename, "/") || StringTools.endsWith(filename, "\\"))
				{
					CLI.print(filename);

					createDirectory(path + "/" + filename);
				}
				else
				{
					// create the file
					var bytes:Bytes = Reader.unzip(entry);

					if (StringTools.endsWith(filename, ".hx") || StringTools.endsWith(filename, ".xml"))
					{
						var text:String = new BytesInput(bytes).readString(bytes.length);

						text = replaceTemplateVars(text);

						bytes = Bytes.ofString(text);

						filename = replaceTemplateVars(filename);
					}
					
					if (StringTools.endsWith(filename, ".hxproj"))
					{
						filename = StringTools.replace(filename, "{{PROJECT_NAME}}", projectName);
					}

					CLI.print(filename);

					var fout:FileOutput = File.write(path + "/" + filename, true);
					fout.writeBytes(bytes, 0, bytes.length);
					fout.close();
				}
			}
		}
		else
		{
			throw "You must provide a directory";
		}
	}

	/**
	 * Creates a directory if it doesn't already exist
	 */
	private function createDirectory(path:String):String
	{
		path = new Path(path).dir;

		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}

		return path;
	}

	private function replaceTemplateVars(text:String):String
	{
		text = StringTools.replace(text, "{{PROJECT_NAME}}", projectName);
		text = StringTools.replace(text, "{{PROJECT_CLASS}}", projectClass);
		text = StringTools.replace(text, "{{WIDTH}}", width);
		text = StringTools.replace(text, "{{HEIGHT}}", height);
		text = StringTools.replace(text, "{{FRAMERATE}}", frameRate);

		return text;
	}

}
