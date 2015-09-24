require 'fileutils'
require 'erb'
module Retrospec
  module Plugins
    module V1
      module ModuleHelpers
        # only creates a directory if the directory doesn't already exist
        def safe_mkdir(dir)
          if File.exists? dir
            unless File.directory? dir
              $stderr.puts "!! #{dir} already exists and is not a directory".fatal
            end
          else
            FileUtils.mkdir_p dir
            puts " + #{dir}/".info
          end
        end

        # copy the symlink and preserve the link
        def safe_create_symlink(src,dest)
          if File.exists? dest
            $stderr.puts "!! #{dest} already exists and differs from template".warning
          else
            FileUtils.copy_entry(src,dest)
            puts " + #{dest}".info
          end
        end

        # safely copy and existing file to another dest
        def safe_copy_file(src, dest)
          if File.exists?(dest) and not File.zero?(dest)
            $stderr.puts "!! #{dest} already exists".warning
          else
            if not File.exists?(src)
              safe_touch(src)
            else
              safe_mkdir(File.dirname(dest))
              FileUtils.cp(src,dest)
            end
            puts " + #{dest}".info
          end
        end

        # touch a file, this is useful for setting up trigger files
        def safe_touch(file)
          if File.exists? file
            unless File.file? file
              $stderr.puts "!! #{file} already exists and is not a regular file".fatal
            end
          else
            FileUtils.touch file
            puts " + #{file}".info
          end
        end

        # safely creates a file and does not override the existing file
        def safe_create_file(filepath, content)
          if File.exists? filepath
            old_content = File.read(filepath)
            # if we did a better comparison of content we could be smarter about when we create files
            if old_content != content or not File.zero?(filepath)
              $stderr.puts "!! #{filepath} already exists and differs from template".warning
            end
          else
            safe_mkdir(File.dirname(filepath)) unless File.exists? File.dirname(filepath)
            File.open(filepath, 'w') do |f|
              f.puts content
            end
            puts " + #{filepath}".info
          end
        end

        # the directory where the config, repos, and other info are saved
        def default_retrospec_dir
          File.expand_path(File.join(ENV['HOME'], '.retrospec' ))
        end

        def retrospec_repos_dir
          File.join(default_retrospec_dir, 'repos')
        end

        # path is the full path of the file to create
        # template is the full path to the template file
        # spec_object is any bindable object which the templates uses for context
        def safe_create_template_file(path, template, spec_object)
          # check to ensure parent directory exists
          file_dir_path = File.expand_path(File.dirname(path))
          if ! File.exists?(file_dir_path)
            Helpers.safe_mkdir(file_dir_path)
          end
          File.open(template) do |file|
            renderer = ERB.new(file.read, 0, '-')
            content = renderer.result spec_object.get_binding
            dest_path = File.expand_path(path)
            safe_create_file(dest_path, content)
          end
        end

      end
    end
  end
end
