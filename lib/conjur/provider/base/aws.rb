require 'aws/sns'

module Conjur
  module Provider
    module Base
      module AWS
        protected      
        
        # Returns an instance variable with the given name, using :create: to
        # initialize it if it's not there.
        def ivar name, &create
          instance_variable_get("@#{name}") || instance_variable_set("@#{name}", instance_eval(&create))
        end
        
        def aws_identity type
          variable = send(:"#{type}_credential")
          JSON.parse(variable.value).symbolize_keys
        end
      end
    end
  end
end
