#
# Copyright (C) 2013 Conjur Inc
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
module Conjur
  class Queue < Resource
    # The name (for example, as passed to aws queues.named) of this queue.
    # Currently we get this directly from the asset identifier
    def queue_name
      identifier.gsub(/[^a-zA-Z0-9_\-]/, '-')
    end
    
    def sender
      queue_role('sender')
    end

    def receiver
      queue_role('receiver')
    end
    
    def sender_credential
      queue_variable('sender')
    end

    def receiver_credential
      queue_variable('receiver')
    end
    
    def key_pair
      Conjur::KeyPair.new(Conjur::Core::API.host, self.options)["key_pairs/#{fully_escape(identifier)}"]
    end
    
    protected
    
    def queue_role(name)
      Conjur::Role.new(Conjur::Authz::API.host, self.options)[Conjur::API.parse_role_id("@queue:#{identifier}/#{name}").join('/')]
    end

    def queue_variable(name)
      Conjur::Variable.new(Conjur::Core::API.host, self.options)["variables/#{fully_escape([ 'queue', identifier, 'credentials', name ].join('/'))}"]
    end
  end
end
