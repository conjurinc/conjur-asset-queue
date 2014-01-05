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
require 'aws'

module Conjur
  module Provisioner
    module Notification
      module AWS
        def provision(options = {})
          iam = options[:iam] || ::AWS::IAM.new
          sns = options[:sns] || ::AWS::SNS.new
          
          sns_topic = sns.topics.create(self.topic_name)

          info_policy = JSON.pretty_generate({
            "Statement" => [
              "Effect" => "Allow",
              "Action" => [ "sns:ListTopics" ],
              "Resource" => [ "*" ]
            ]
          })
          
          sender = iam.users.create("sys_notification_#{self.identifier}_sender".parameterize, path: '/' + self.identifier + '/')
          sender.policies['send'] = JSON.pretty_generate({
            "Statement" => [
              "Effect" => "Allow",
              "Action" => [ "sns:Publish" ],
              "Resource" => [ sns_topic.arn ]
            ]})
          sender.policies['info'] = info_policy
                    
          sender_access_key = sender.access_keys.create
          self.sender_credential.add_value({ access_key_id: sender_access_key.id, secret_access_key: sender_access_key.secret }.to_json)
        end
      end
    end
  end
end
