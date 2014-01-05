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
require 'conjur/notification'

module Conjur
  class API
    def create_notification(id, options = {})
      provider = options[:provider] || :aws
      
      create_resource notification_resourceid(id), options
      
      sender   = create_role notification_roleid(id, 'sender'), options
      sender_credential   = create_variable 'application/json', "#{provider}-identity", options.merge(id: [ 'notification', id, 'credentials/sender' ].join('/'))

      sender_credential.resource.permit   :execute, sender.roleid

      notification(id)
    end
    
    def notification id
      Conjur::Notification.new(resource(notification_resourceid(id)).url, credentials)
    end
    
    protected
    
    def notification_resourceid(id)
      [ Conjur::Core::API.conjur_account, 'notification', id ].join(':')
    end

    def notification_roleid(id, name)
      [ Conjur::Core::API.conjur_account, '@notification', [ id, name ].join('/') ].join(':')
    end
  end
end
