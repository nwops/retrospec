module Retrospec
  module Plugins
    module V1
      class ContextObject
        def get_binding
          binding
        end
      end
    end
  end
end