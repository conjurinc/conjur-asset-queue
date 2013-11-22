require 'spec_helper'

describe Conjur::API do
  let(:id) { 'the/queue' }
  let(:options) { { foo: 'bar' } }
  let(:token) { :the_token }
  let(:api) { Conjur::API.new_from_token(token) }
  
  before {
    Conjur::Core::API.stub(:conjur_account).and_return 'the-account'
  }
  
  context "#create_queue" do
    it 'creates expected roles and assets' do
      sender_credential_resource   = double(:sender_credential_resource)
      receiver_credential_resource = double(:receiver_credential_resource)
      key_pair = double(:key_pair)
      
      api.should_receive(:create_resource).with('the-account:queue:the/queue', options)
      api.should_receive(:create_role).with('the-account:@queue:the/queue/sender', options).and_return double(:sender, roleid: 'sender-roleid')
      api.should_receive(:create_role).with('the-account:@queue:the/queue/receiver', options).and_return double(:receiver, roleid: 'receiver-roleid')
      api.should_receive(:create_variable).with('application/json', 'aws-identity', options.merge(id: 'the/queue/credentials/sender')).and_return double(:sender_credential, resource: sender_credential_resource)
      api.should_receive(:create_variable).with('application/json', 'aws-identity', options.merge(id: 'the/queue/credentials/receiver')).and_return double(:receiver_credential, resource: receiver_credential_resource)
      api.should_receive(:create_key_pair).with(options.merge(id: 'the/queue')).and_return key_pair
      
      sender_credential_resource.should_receive(:permit).with(:execute, 'sender-roleid')
      receiver_credential_resource.should_receive(:permit).with(:execute, 'receiver-roleid')
      
      key_pair.should_receive(:add_member).with('encrypt', 'sender-roleid')
      key_pair.should_receive(:add_member).with('decrypt', 'receiver-roleid')
      
      api.create_queue id, options
    end
  end
  
  context "#queue" do
    subject { api.queue id }

    its(:url) { should == "http://localhost:5100/the-account/resources/queue/the/queue" }
    
    it 'propagates options' do
      subject.options.keys.should include(:headers)
      subject.options[:headers].keys.should include(:authorization)
    end
  end
end