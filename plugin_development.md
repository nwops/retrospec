# Retrospec plugin development

If you wish to automate the creation of a project or other project plugins you should
create a retrospec plugin. Follow the steps below to create a plugin.

## Creating a plugin using the plugin generator
1. Install the retrospec plugin that creates retrospec plugins!  `gem install retrospec-plugingen`
2. Come up with a name for you plugin.
3. Use the retrospec plugin help `retrospec -m /path_to_project/plugin_name plugingen -h`
4. Create the plugin `retrospec -m /path_to_project/plugin_name plugingen`
5. Open the /path_to_project/plugin_name in your favorite editor
6. Hack --> Test --> Publish

## Choosing a plugin name
By deafult the plugin generator will use the name of the directory or the name specified via the -n option.  This name
will used through the generator templates so its important to pick a sensible name.  The generator also uses the plugin_name
as a class name although you are free to change it after creation. 

## What you need to override
