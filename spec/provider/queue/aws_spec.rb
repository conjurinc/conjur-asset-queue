require 'conjur/provider/queue/aws'

describe Conjur::Provider::Queue::AWS do
  let(:id) { 'the-queue' }
  let(:url) { "http://localhost:5100/the-account/resources/queue/#{id}" }
  let(:queue) { 
    Conjur::Queue.new(url, {}).tap do |queue|
      class << queue
        include Conjur::Provider::Queue::AWS
      end
    end
  }
  
  let(:read_identity){ {secret_access_key: 'read secret', access_key_id: 'read id'} }
  let(:write_identity){ {secret_access_key: 'write secret', access_key_id: 'write id'} }

  before do
    queue.stub(sender_credential: double("write_identity", value: write_identity.to_json))
    queue.stub(receiver_credential: double("read_identity", value: read_identity.to_json))
  end
  
  describe "queue construction" do
    let(:api) { double('conjur api') }
    let(:sqs) { double('sqs client') }
    describe "SQS client API" do
      specify {
        ::AWS::SQS.should_receive(:new).with(read_identity).and_return sqs
        queue.sqs_receiver.should == sqs
      }
      specify {
        ::AWS::SQS.should_receive(:new).with(write_identity).and_return sqs
        queue.sqs_sender.should == sqs
      }
    end
    
    describe "SQS queue" do
      before {
        queues = double('queue collection')
        queue_client.should_receive(:queues).and_return queues
        queues.should_receive(:named).with(queue.queue_name).and_return 'the queue'
      }
      describe '#sqs_inbound_queue' do
        let(:queue_client){ queue.sqs_reader }
        specify {
          queue.sqs_inbound_queue
        }
      end
      
      describe '#sqs_outbound_queue' do
        let(:queue_client){ queue.sqs_writer }
        specify {
          queue.sqs_outbound_queue
        }
      end
    end
  end
  
  describe '#send_message' do
    let(:encrypted){ 'gobledegook' }
    let(:sqs_queue){ double('sqs queue') }
    before do
      queue.stub(sqs_outbound_queue: sqs_queue, encrypt_message: encrypted)
    end
    
    it 'sends the message on #sqs_outbound_queue' do
      sqs_queue.should_receive(:send_message).with(encrypted, {})
      queue.send_message "boo!"
    end
    
    it 'allows passing options to queue.send_message' do
      sqs_queue.should_receive(:send_message).with(encrypted, delay_seconds: 10)
      queue.send_message "boo!", delay_seconds: 10
    end
  end
  
  describe "message encryption" do
    let(:encrypted){ 'gobledegook' }
    let(:key_pair){ double('key pair') }
    let(:sqs_queue){ double('sqs queue') }
    before do
      queue.stub(sqs_outbound_queue: sqs_queue, key_pair: key_pair)
    end

    it 'encrypts the message with key pair given by config.encrypt_key_pair' do
      key_pair.should_receive(:encrypt).with("boo!").and_return encrypted
      sqs_queue.should_receive(:send_message).with(encrypted, {})
      queue.send_message "boo!"
    end
  end
end