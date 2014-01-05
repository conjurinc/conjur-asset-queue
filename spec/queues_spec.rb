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
      api.should_receive(:create_variable).with('application/json', 'aws-identity', options.merge(id: 'queue/the/queue/credentials/sender')).and_return double(:sender_credential, resource: sender_credential_resource)
      api.should_receive(:create_variable).with('application/json', 'aws-identity', options.merge(id: 'queue/the/queue/credentials/receiver')).and_return double(:receiver_credential, resource: receiver_credential_resource)
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