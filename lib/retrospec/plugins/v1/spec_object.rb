module Retrospec
  module Plugin
    module V1
      class SpecObject
        attr_accessor :instance

        def initialize(data)
          @instance = data
        end

        def module_path
          instance['module_path']
        end

        def module_name
          instance['plugin_name']
        end

        def get_binding
          binding
        end
      end
    end
  end
end