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
require 'spec_helper'

require 'conjur/provisioner/queue/aws'

describe Conjur::Provisioner::Queue::AWS do
  let(:id) { 'the/queue' }
  let(:url) { "http://localhost:5100/the-account/resources/queue/#{id}" }
  let(:options) { { foo: 'bar' } }
  let(:queue) { 
    Conjur::Queue.new(url, options).tap do |queue|
      class << queue
        include Conjur::Provisioner::Queue::AWS
      end
    end
  }
  
  before {
    stub_request(:get, "http://169.254.169.254/latest/meta-data/iam/security-credentials/")
  }
  
  context "#provision" do
    let(:sqs) { AWS::SQS.any_instance }
    let(:iam) { AWS::IAM.any_instance }
    
    it "provisions the queue" do
      sqs.should_receive(:queues).and_return queues = double(:queues)
      queues.should_receive(:create).with("the-queue").and_return sqs_queue = double(:queue, arn: 'the-arn')

      iam.stub(:users).and_return users = double(:users)
      
      users.should_receive(:create).with("sender", path: '/' + id).and_return sender = double(:user, policies: (sender_policies = double(:policies)))
      sender_policies.should_receive(:[]=).with('send', an_instance_of(Hash)) do |name, policy|
        JSON.parse(policy.to_json).should == {"Statement"=>[{"Effect"=>"Allow","Action"=>["sqs:SendMessage"],"Resource"=>["the-arn"]}]}
      end
      
      users.should_receive(:create).with("receiver", path: '/' + id).and_return receiver = double(:user, policies: (receiver_policies = double(:policies)))
      receiver_policies.should_receive(:[]=).with('receive', an_instance_of(Hash))

      sender.stub_chain(:access_keys, :create).and_return double(:key, id: 'sender-key-id', secret: 'sender-key-secret')
      receiver.stub_chain(:access_keys, :create).and_return double(:key, id: 'receiver-key-id', secret: 'receiver-key-secret')

      queue.stub_chain(:sender_credential, :add_value).with("{\"access_key_id\":\"sender-key-id\",\"secret_access_key\":\"sender-key-secret\"}")
      queue.stub_chain(:receiver_credential, :add_value).with("{\"access_key_id\":\"receiver-key-id\",\"secret_access_key\":\"receiver-key-secret\"}")

      queue.provision
    end
  end
end