require 'aws/sns'

module Conjur
  module Provider
    module Notification
      module AWS
        def self.included(base)
          base.module_eval do
            require 'conjur/provider/base/aws'
            include Conjur::Provider::Base::AWS
          end
        end
        
        # @return [AWS::SNS] SNS client with credentials from the notification asset's
        #   sender identity (which has permission to send messages)
        def sns_sender
          ivar(:sns_sender){ new_sns_client(:sender) }
        end
        alias sns_writer sns_sender
        
        # @return [AWS::SNS::Topic] topic to which we send messages. 
        def sns_topic(region, account)
          ivar(:sns_topic){ sns_sender.topics[topic_arn(region, account)] }
        end
        
        # Sends an SNS message to ourself.
        # @param [*] body A string or value to send.  When not a string,
        #   it will be serialized as JSON.  This message will be encrypted
        #   using the notification asset's key pair.
        # @param [Hash] opts Options to pass as the second argument to send_message.
        def publish subject, body, opts={}
          sns_topic(opts[:region] || "us-east-1", opts[:account]).publish body, {subject: subject}.merge(opts)
        end
        
        def topic_arn(region, account)
          "arn:aws:sns:#{region}:#{account}:#{topic_name}"
        end
        
        private      
        
        # Create an SNS client using the specified credential
        # @param type [String,Symbol] :sender or :receiver
        def new_sns_client type
          ::AWS::SNS.new aws_identity(type)
        end
      end
    end
  end
end