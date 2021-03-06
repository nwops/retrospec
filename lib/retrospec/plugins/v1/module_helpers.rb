require 'fileutils'
require 'erb'
require 'find'
module Retrospec
  module Plugins
    module V1
      module ModuleHelpers

        # stores the answer if the user wants to overwrite all files
        # @return [Boolean]  true if overwrite_all mode is enabled
        def overwrite_all
          @@overwrite_all ||= !ENV['RETROSPEC_OVERWRITE_ALL'].nil?
        end

        # @return [Boolean]  true if overwrite mode is enabled
        def overwrite_enabled?
          !ENV['RETROSPEC_OVERWRITE_ENABLE'].nil?
        end

        # notifies the user of what action will be performed
        # + creates a file
        # - + overwrites a file
        def notify(dest, overwrite=false)
          if overwrite
            puts " - + #{dest}".info
          else
            puts " + #{dest}".info
          end
        end

        # creates the content, then notifies the user
        def create_content(type, dest, src = nil, overwrite = false)
          case type
            when :file
              File.open(dest, 'w') do |f|
                f.puts(src)
              end
            when :dir
              FileUtils.mkdir_p(dest)
            when :link
              FileUtils.copy_entry(src,dest,false,false,true) # always remove destination
            when :mv
              FileUtils.mv(src,dest)
            when :touch
              FileUtils.touch(dest)
            when :cp
              FileUtils.cp(src,dest)
          end
          notify(dest, overwrite)
        end

        # @returns [Boolean] true if the user wants to overwrite the dest
        # sets @overwrite_all if the user chooses 'a' and saves for next time
        # @param dest [String] - the destination of the file
        def overwrite?(dest)
          return true if overwrite_all
          return false unless overwrite_enabled?
          answer = prompt_for_overwrite(dest)
          if answer == 'a'
            print "Are you sure you wish to overwrite all generated files?(y/n): ".fatal
            sure = gets.chomp.downcase
            return @@overwrite_all = true if sure == 'y'
            overwrite?(dest)
          else
            answer == 'y'
          end
        end

        def prompt_for_overwrite(dest)
          print "Overwrite #{dest}?(y/n/a): ".cyan
          gets.chomp.downcase
        end

        # only creates a directory if the directory doesn't already exist
        def safe_mkdir(dir)
          dir = File.expand_path(dir)
          if File.exists? dir
            unless File.directory? dir
              $stderr.puts "!! #{dir} already exists and is not a directory".fatal
            end
          else
            create_content(:dir, dir)
          end
        end

        # @param [String] - destination of the file
        # @return [Bool] - true if the file should be synced
        # determines if the file should be synced by checking if the any of the file extensions
        # have the word sync
        def sync_file?(file)
          filename = File.basename(file)
          parts = filename.split('.')
          parts.include?('sync')
        end

        # @param [String] - destination of the file
        # @return [Bool] - true if the file should be synced
        # determines if the contains the extension retrospec
        # have the word sync
        def retrospec_file?(file)
          filename = File.basename(file)
          parts = filename.split('.')
          parts.include?('retrospec')
        end

        # @param [String] - destination of the file
        # @param [Bool] - true if the file should be synced
        # @return [Bool] - true if the file should be created or overwritten
        def should_create?(dest, sync_file = false)
          return true unless File.exists?(dest)
          return true if sync_file
          return true if overwrite?(dest)
          return true if File.zero?(dest)
          false
        end

        # move the file, safely
        def safe_move_file(src,dest)
          unless should_create?(dest)
            return $stderr.puts "!! #{dest} already exists and differs from template".warning
          end
          create_content(:mv, dest, src)
        end

        # copy the symlink and preserve the link
        def safe_create_symlink(src,dest)
          unless should_create?(dest)
            return $stderr.puts "!! #{dest} already exists and differs from template".warning
          end
          create_content(:link, dest, src)
        end

        # safely copy an existing file to another dest
        def safe_copy_file(src, dest, sync_file = false)
          unless should_create?(dest, sync_file)
            return $stderr.puts "!! #{dest} already exists".warning
          end
          return safe_touch(src) unless File.exists?(src)
          safe_mkdir(File.dirname(dest))
          create_content(:cp, dest, src)
        end

        # touch a file, this is useful for setting up trigger files
        def safe_touch(file)
          if File.exists? file
            unless File.file? file
              $stderr.puts "!! #{file} already exists and is not a regular file".fatal
            end
          else
            create_content(:touch, file)
          end
        end

        # safely creates a file and does not override the existing file
        def safe_create_file(dest, content, sync_file = false)
          unless should_create?(dest, sync_file)
            old_content = File.read(dest)
            # if we did a better comparison of content we could be smarter about when we create files
            if old_content != content
              $stderr.puts "!! #{dest} already exists and differs from template".warning
            end
          else
            safe_mkdir(File.dirname(dest)) unless File.exists? File.dirname(dest)
            create_content(:file, dest, content)
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
        def safe_create_template_file(path, template, spec_object, sync_file = false)
          # check to ensure parent directory exists
          file_dir_path = File.expand_path(File.dirname(path))
          safe_mkdir(file_dir_path) unless File.exists?(file_dir_path)
          File.open(template) do |file|
            renderer = ERB.new(file.read, 0, '-')
            content = renderer.result spec_object.get_binding
            dest_path = File.expand_path(path)
            safe_create_file(dest_path, content, sync_file)
          end
        end

        # creates any file that is contained in the templates_dir directory structure
        # loops through the directory looking for erb files or other files.
        # strips the erb extension and renders the template to the current module path
        # filenames must named how they would appear in the normal module path.  The directory
        # structure where the file is contained
        # @param [String] template directory of where to find templates
        # @param [String] module_path - path to the module
        # @param [String] spec_object - the context that is used for template rendering
        # @param [String] filter - a regex string used to filter out files
        def safe_create_directory_files(template_dir, module_path, spec_object, filter = nil)
          templates = Find.find(template_dir).sort
          templates.each do |template|
            next if template =~ filter
            dest = template.gsub(template_dir, module_path)
            if File.symlink?(template)
              safe_create_symlink(template, dest)
            elsif File.directory?(template)
              safe_mkdir(dest)
            else
              # because some plugins contain erb files themselves any erb file will be copied only
              # so we need to designate which files should be rendered with .retrospec.erb
              # render any file ending in .retrospec_erb as a template
              sync_file = sync_file?(template)
              retrospec_file = retrospec_file?(template)
              dest = dest.gsub(/\.sync/, '') if sync_file
              if retrospec_file
                dest = dest.gsub(/\.retrospec\.erb/, '')
                safe_create_template_file(dest, template, spec_object, sync_file)
              else
                safe_copy_file(template, dest, sync_file)
              end
            end
          end
        end



        # creates any file that is contained in the templates/modules_files directory structure
        # loops through the directory looking for erb files or other files.
        # strips the erb extension and renders the template to the current module path
        # filenames must named how they would appear in the normal module path.  The directory
        # structure where the file is contained
        # @param [String] template directory of where to find templates
        # @param [String] module_path - path to the module
        # @param [String] spec_object - the context that is used for template rendering
        # @param [String] filter - a regex string used to filter out files
        def safe_create_module_files(template_dir, module_path, spec_object, filter = nil)
          dir = File.join(template_dir,'module_files')
          safe_create_directory_files(dir, module_path, spec_object, filter)
        end
      end
    end
  end
end
