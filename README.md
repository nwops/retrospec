# Retrospec

[![Gem Version](https://badge.fury.io/rb/retrospec.svg)](http://badge.fury.io/rb/retrospec)
[![Build Status](https://travis-ci.org/nwops/retrospec.png)](https://travis-ci.org/nwops/retrospec)

Retrospec is a framework that allows the automation of repetitive project file creation with just about any kind of programming
project through the use of a pluggable architecture.

The idea originally came from another project that performed the same function but was scoped to puppet module creation
called [puppet-retrospec](https://github.com/nwops/puppet-retrospec.git). The goal of puppet-retrospec was to document
the workflow and its best practices inside templates. This idea has now been generalized to cover any kind of project,
therefore making it dead simple for anybody to get their project started with a simple command.

There are two scenarios that this gem can be used for.

1. Initial project creation
2. Project augmentation

The first scenario is to aid the creation of the project as many times information is spread across people, teams, blogs,
forums and is often out of date. By keeping this information in templates we have removed the burden of finding this
information from the user. However, there are many tools in existence today that already help in this area, but they
are often not customizable.

The second scenario it to augment an existing project that a user may have already started. When this is the case
retrospec can "retrofit" an existing project with the latest workflow and best practices based on the templates inside
a plugin gem. An existing project also contains information that can be used to automatically generate lots of files beyond just
initial module creation. A great example of this is with [puppet-retrospec](https://github.com/nwops/puppet-retrospec.git),
where the goal is to automaticly generate valid unit tests based on the code the author wrote. So as the user writes more
code, they can easily create unit test files by just running retrospec.

Furthermore, retrospec is meant to be run multiple times during a project lifecycle in order to augment it with new files.
Because of the safe file creation, no file can be overwritten so the only way to overcome this is to manually delete the
file and let retrospec recreate it automatically.

This idea is inspried by a few projects:

- maven archetypes
- jeweler ruby gem
- puppet-lint

## Install

`gem install retrospec`

## Known issues

If you have previously installed the puppet-retrospec gem, there is a conflict with the executable file `retrospec` because
this gem also uses an executable file with the same name. As a result I will be moving the legacy puppet-retrospec gem
to a retrospec plugin that performs the same functionality. But first I have to release this gem and the plugingem in order
to move the puppet-retrospec to a plugin.

## Usage

### List Available Plugins

By default the retrospec gem does not do anything but provide a framework for plugins. In order to do anything you will
need to install a retrospec plugin. To see a list of plugins use: `retrospec -a` which will query the following [url](https://raw.githubusercontent.com/nwops/retrospec/master/available_plugins.yaml).

### Setting the module path

Setting the module path is the only option that can change the outcome of the plugin. By default it will use the current
directory, but this can be overridden by using the `retrospec -m` option.

### Subcommands

Subcommands are added dynamically to the help screen when installing new retrospec plugins.
So just use `retrospec -h` to see the list. The name of the plugin is usually the name of subcommand.

```
retrospec -h
A framework to automate your development workflow by generating common files and test patterns.

Usage: retrospec [global options] subcommand [subcommand options]
Available subcommands:
plugingen
  -m, --module-path=<s>      The path (relative or absolute) to the module directory (default: /Users/cosman/github/retrospec)
  -a, --available-plugins    Show an online list of available plugins
  -v, --version              Print version and exit
  -h, --help                 Show this message
```

Note: If you are really good at optimist and can suggest a better way to display subcommands please let me know. I was going
for a git like interface but came up short.

### Using subcommands

Once you find the subcommand you want just run the subcommand like: `retrospec -m tmp/test4 plugingen`. If you
have already created your project you don't need to pass the `-m` option if your current working directory
is the root of your project. So you may find yourself running `retrospec plugin_name` often inside your project.

Getting help with a subcommand is easy as using `retrospec -m tmp/test4 plugin_name -h`

```
% retrospec -m /tmp/new_retrospec_plugin plugingen -h
Options:
  -n, --name=<s>    The name of the new plugin (default: new_retrospec_plugin)
  -h, --help        Show this message
```

### Retrspec config file

Retrospec will read the config file at ~/.retrospec/config.yaml for configs related to retrospec itself or any plugins
you install. Since you may be running retrospec over and over it will be annoying to always have to specify this info
so please refer to the plugin documentation for which options you can save to the config file. At this time there are
no retrospec config options being read form the config file. By default retrospec will add a simple config to ~/.retrospec

## Plugins

Please see the following [list](https://raw.githubusercontent.com/nwops/retrospec/master/available_plugins.yaml) for available plugins.

## Plugin development and future plugin ideas

Please see the [plugin document](plugin_development.md) for creating new retrospec plugins.

Some ideas I have in my head for future plugins that should be created.

- foreman plugin generator
- foreman hammer cli plugin generator
- smart-proxy plugin generator
- nodejs project generator
- chef module generator
- ansible module generator
- saltstack module generator (possibly multiple types of plugins to create here)
- groovy project generator
- puppet module generator (in progress)

The sky is really the limit for what we can create since the usage is limited to any project that contains files.

## Special file extensions

- If a file contains `.sync` the file will be always be synced
- If a file contains `.retrospec.erb` this tells retrospec that the file should be rendered as an erb file

## Contributing to retrospec

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
- Fork the project.
- Start a feature/bugfix branch.
- Commit and push until you are happy with your contribution.
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Corey Osman. See LICENSE.txt for
further details.

## Paid Support

Want to see new features developed much faster? Contact me about a support contract so I can develop this tool during
the day instead of after work. contact: sales@logicminds.biz
