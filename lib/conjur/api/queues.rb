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
require 'conjur/queue'

module Conjur
  class API
    def create_queue(id, options = {})
      provider = options[:provider] || :aws
      
      create_resource queue_resourceid(id), options
      
      sender   = create_role queue_roleid(id, 'sender'), options
      receiver = create_role queue_roleid(id, 'receiver'), options
      sender_credential   = create_variable 'application/json', "#{provider}-identity", options.merge(id: [ id, 'credentials/sender' ].join('/'))
      receiver_credential = create_variable 'application/json', "#{provider}-identity", options.merge(id: [ id, 'credentials/receiver' ].join('/'))
      key_pair = create_key_pair options.merge(id: id)

      sender_credential.resource.permit   :execute, sender.roleid
      receiver_credential.resource.permit :execute, receiver.roleid

      key_pair.add_member 'encrypt', sender.roleid
      key_pair.add_member 'decrypt', receiver.roleid
      
      queue(id)
    end
    
    def queue id
      Conjur::Queue.new(resource(queue_resourceid(id)).url, credentials)
    end
    
    protected
    
    def queue_resourceid(id)
      [ Conjur::Core::API.conjur_account, 'queue', id ].join(':')
    end

    def queue_roleid(id, name)
      [ Conjur::Core::API.conjur_account, '@queue', [ id, name ].join('/') ].join(':')
    end
  end
end
