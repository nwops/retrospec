module Retrospec
  module Plugin
    module V1
      class SpecObject
        attr_accessor :instance

        def initialize(mod_instance)
          @instance = mod_instance
        end

        def module_path
          instance.module_path
        end

        def module_name
          instance.module_name
        end

        def get_binding
          binding
        end

      end
    end
  end
end