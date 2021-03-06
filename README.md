# Conjur::Asset::Queue

Implements secure queue communication. 

A Queue is composed of:

* **resource** a base resource
* **sender** a role with permission to send to the queue
* **receiver** a role with permission to receive from the queue
* **sender_credential** a queue credential, executable by `sender`
* **receiver_credential** a queue credential, executable by `receiver`
* **key_pair** used by `sender` to encrypt (or sign) messages, and by `receiver` to decrypt/verify them.

## Installation

Add this line to your application's Gemfile:

    gem 'conjur-asset-queue'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install conjur-asset-queue

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
