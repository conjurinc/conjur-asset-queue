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

describe Conjur::Queue do
  let(:id) { 'the/queue' }
  let(:url) { "http://localhost:5100/the-account/resources/queue/#{id}" }
  let(:options) { { foo: 'bar' } }
  let(:queue) { Conjur::Queue.new(url, options) }
  let(:api) { double(:api) }
  
  subject { queue }
  
  before {
    queue.stub(:api).and_return api
  }

  before {
    Conjur::Core::API.stub(:conjur_account).and_return 'the-account'
  }
    
  context "#sender" do
    subject { queue.sender }
    its(:class) { should == Conjur::Role }
    its(:url) { should == "http://localhost:5100/the-account/roles/@queue/the/queue/sender" }
  end
  context "#sender_credential" do
    subject { queue.sender_credential }
    its(:class) { should == Conjur::Variable }
    its(:url) { should == "http://localhost:5200/variables/the%2Fqueue%2Fcredentials%2Fsender" }
  end
  context "#key_pair" do
    subject { queue.key_pair }
    its(:class) { should == Conjur::KeyPair }
    its(:url) { should == "http://localhost:5200/key_pairs/the%2Fqueue" }
  end
end