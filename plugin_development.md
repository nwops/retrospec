# Retrospec plugin development

If you wish to automate the creation of a project or other project plugins you should
create a retrospec plugin. Follow the steps below to create a plugin.

## Creating a plugin using the plugin generator

1. Install the retrospec plugin that creates retrospec plugins! `gem install retrospec-plugingen`
2. Come up with a name for you plugin.
3. Use the retrospec plugin help `retrospec -m /path_to_project/plugin_name plugingen -h`
4. Create the plugin `retrospec -m /path_to_project/plugin_name plugingen`
5. Open the /path_to_project/plugin_name in your favorite editor
6. Hack --> Test --> Publish

## Choosing a plugin name

By default the plugin generator will use the name of the directory or the name specified via the -n option. This name
will be used throughout the generator templates so its important to pick a sensible name. The generator also uses the plugin_name
as a class name although you are free to change it after creation.

### Naming the gem and repo

Please ensure the gem name uses the following naming scheme retrospec-plugin_name and that your repo is also named retrospec-plugin_name.
This will help everyone identify what the repo and gem do.

Note: puppet-retrospec does not follow this standard due to a legacy name issue that would have caused confusion.

## What you need to override

- self.run_cli

## Create a context object

By default the plugin generator will create a context object that can be used inside templates. The default context object
does not contain anything useful so you will want to customize this object only if your templates require variable interpolation.

## Main method to override

Retrospec will call your plugin by running the plugin.run_cli class method. You can do whatever you want in this method.

The global_opts are the options passed into the retrospec command which are specific to retrospec. Additionally, the
global_config (~/.retrospec/config.yaml) is a hash map of the entire config while the plugin_config is a subset that pertains
only to your plugin.

In this method you should at least call self.new() on your plugin and then plugin_instance.run.

For simplicity sake you can also just copy and paste this into your method. This is the default layout when using
the retrospec plugin generator.

```ruby
def self.run_cli(global_opts, global_config, plugin_config)
 # a list of subcommands for this plugin
    sub_commands  = []
    if sub_commands.count > 0
      sub_command_help = "Subcommands:\n#{sub_commands.join("\n")}\n"
    else
      sub_command_help = ""
    end
    plugin_opts = optimist::options do
      version "#{Retrospec::Pluginname::VERSION} (c) Your Name"
      banner <<-EOS
Some description goes here.\n
#{sub_command_help}

    EOS
    opt :option1, "Some fancy option"
    stop_on sub_commands
  end
  # the passed in options will always override the config file
  plugin_data = plugin_opts.merge(global_config).merge(global_opts).merge(plugin_opts)
  # define the default action to use the plugin here, the default is run
  sub_command = (ARGV.shift || :run).to_sym
  # create an instance of this plugin
  plugin = self.new(plugin_data[:module_path],plugin_data)
  # check if the plugin supports the sub command
  if plugin.respond_to?(sub_command)
    plugin.post_init   # finish initialization
    plugin.send(sub_command)
  else
    puts "The subcommand #{sub_command} is not supported or valid"
    exit 1
  end
end
```

See the [optimist documentation](http://optimist.rubyforge.org) for more info.

## Module helpers

The module helpers module is included by default and contains useful methods to safely create files. When creating files
use the safe create methods in order to protect the users content from being overwritten.  
For a list of methods please see the [source code](https://github.com/nwops/retrospec/blob/master/lib/retrospec/plugins/v1/module_helpers.rb)
