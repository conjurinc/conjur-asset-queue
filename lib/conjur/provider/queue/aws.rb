require 'aws/sqs'

module Conjur
  module Provider
    module Queue
      module AWS
        def self.included(base)
          base.module_eval do
            require 'conjur/provider/base/aws'
            include Conjur::Provider::Base::AWS
          end
        end
        
        # @return [AWS::SQS] SQS client with credentials from the queue asset's
        #   receiver identity (which has permission to receive/delete/hide messages)
        def sqs_receiver
          ivar(:sqs_receiver){ new_sqs_client(:receiver) }
        end
        alias sqs_reader sqs_receiver
        
        # @return [AWS::SQS] SQS client with credentials from the queue asset's
        #   sender identity (which has permission to send messages)
        def sqs_sender
          ivar(:sqs_sender){ new_sqs_client(:sender) }
        end
        alias sqs_writer sqs_sender
        
        # @return [AWS::SQS::Queue] queue from which we receive launch requests
        def sqs_inbound_queue
          ivar(:sqs_inbound_queue){ sqs_receiver.queues.named queue_name }
        end
        
        # @return [AWS::SQS::Queue] queue to which we send messages.  The
        #   difference between this and sqs_inbound_queue is that this queue is configured
        #   to use the sender AWS identity, while #sqs_inbound_queue uses the receiver
        #   identity.
        def sqs_outbound_queue
          ivar(:sqs_outbound_queue){ sqs_sender.queues.named queue_name }
        end
        
        # Sends an SQS message to the outbound queue.
        # @param [*] body A string or value to send.  When not a string,
        #   it will be serialized as JSON.  This message will be encrypted
        #   using the queue asset's key pair.
        # @param [Hash] opts Options to pass as the second argument to send_message.
        def send_message body, opts={}
          require 'base64'
          body = body.to_json unless body.kind_of?(String)
          sqs_outbound_queue.send_message Base64.encode64(encrypt_message(body)), opts
        end
              
        # Decrypt a message received from our queue.
        # @param [String] ciphertext text to decrypt
        def decrypt_message ciphertext
          key_pair.decrypt ciphertext
        end
  
        # Encrypt a message to be sent on our queue (that is, to ourselves)
        # @param [String] plaintext text to encrypt
        def encrypt_message plaintext
          key_pair.encrypt plaintext
        end
        
        private      
        
        # Create an SQS client using the specified credential
        # @param type [String,Symbol] :sender or :receiver
        def new_sqs_client type
          ::AWS::SQS.new aws_identity(type)
        end
      end
    end
  end
end