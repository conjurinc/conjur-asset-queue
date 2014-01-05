require "bundler/gem_tasks"

task :initialize do |t, args|
  require 'conjur/cli'
  require 'conjur-asset-queue'
  
  Conjur::Config.load
  Conjur::Config.apply
  
  @api = Conjur::API.new_from_key(*Conjur::Authn.get_credentials(noask: true))
end

namespace :queue do
  task :create, [:queue_id] => :initialize do |t, args|
    queue_id = args[:queue_id] or raise "Missing 'queue_id'"
    
    @api.create_queue queue_id
  end
  
  task :provision, [:provider, :queue_id, :credential] => :initialize do |t, args|
    provider = args[:provider] or raise "Missing 'provider'"
    raise "Provider not supported" unless provider == 'aws'
    queue_id = args[:queue_id] or raise "Missing 'queue_id'"
    credential = args[:credential] or raise "Missing 'credential'"
    
    require 'aws'
    require 'json'
    require 'conjur/provisioner/queue/aws'
  
    class Conjur::Queue
      include Conjur::Provisioner::Queue::AWS
    end
    
    credentials = JSON.parse(@api.variable(credential).value).symbolize_keys
    ::AWS.config(access_key_id: credentials[:access_key_id], secret_access_key: credentials[:secret_access_key])
    queue = @api.queue(queue_id)
    queue.provision
    
    puts queue.sender_credential
    puts queue.receiver_credential
  end
end

namespace :notification do
  task :create, [:notification_id] => :initialize do |t, args|
    notification_id = args[:notification_id] or raise "Missing 'notification_id'"
    
    @api.create_notification notification_id
  end
  
  task :provision, [:provider, :notification_id, :credential] => :initialize do |t, args|
    provider = args[:provider] or raise "Missing 'provider'"
    raise "Provider not supported" unless provider == 'aws'
    notification_id = args[:notification_id] or raise "Missing 'notification_id'"
    credential = args[:credential] or raise "Missing 'credential'"
    
    require 'aws'
    require 'json'
    require 'conjur/provisioner/notification/aws'
  
    class Conjur::Notification
      include Conjur::Provisioner::Notification::AWS
    end
    
    credentials = JSON.parse(@api.variable(credential).value).symbolize_keys
    ::AWS.config(access_key_id: credentials[:access_key_id], secret_access_key: credentials[:secret_access_key])
    notification = @api.notification(notification_id)
    notification.provision
    
    puts notification.sender_credential
  end
  
  task :publish, [:provider, :notification_id, :region, :account, :subject, :body] => :initialize do |t, args|
    provider = args[:provider] or raise "Missing 'provider'"
    raise "Provider not supported" unless provider == 'aws'
    notification_id = args[:notification_id] or raise "Missing 'notification_id'"
    
    require 'conjur/provider/notification/aws'
  
    class Conjur::Notification
      include Conjur::Provider::Notification::AWS
    end
    
    @api.notification(notification_id).publish args[:subject], args[:body], account: args[:account], region: args[:region]
  end
end