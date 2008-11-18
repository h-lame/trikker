#!ruby
#!/usr/local/bin/ruby -rubygems
require 'rubygems'

gem 'camping'
gem 'reststop'
gem 'json'

require 'camping'
require 'basic_authentication'
require 'reststop'
require 'json'

Camping.goes :Trikker

module Trikker
  include Camping::BasicAuth
  def self.authenticate(u, p)
    [u,p] == ['hlame', 'woo']
  end
end

module Trikker::Controllers
  def self.endpoint(controller_name, routes, methods, formats, &blck)
    f = "\.(#{[*formats].join('|')})"
    [*routes].map {|r| r + f}
    klass = self.const_set(controller_name.to_s, Class.new(R([*routes].map {|r| r + f})))
    klass.class_eval do
      [*methods].each do |meth|
        define_method meth, &blck
      end
    end
  end
  
  endpoint :Timelines, '/statuses/(public|friends|user)_timeline', :get, [:xml, :json, :rss, :atom] do |timeline_type, format|
  end
  
  endpoint :StatusUpdate, '/statues/update', :get, [:xml, :json] do |format|
  end
  
  endpoint :ShowAStatus, '/statuses/show/(\d+)', :get, [:xml, :json] do |id, format|
  end
    
  endpoint :StatusReplies, '/statuses/replies', :get, [:xml, :json, :rss, :atom] do |format|
  end
  
  endpoint :StatusFriendsAndFollowers, '/statuses/(friends|followers)', :get, [:xml, :json] do |friend_or_follower, format|
  end
  
  endpoint :DestroyAStatus, '/statuses/destroy/(\d+)', [:post, :delete], [:xml, :json] do |id, format|
  end
  
  # NOTE - technically /users/show.xml?email=blah@blah.com is valid too...
  endpoint :ShowAUser, '/users/show/([a-zA-Z\d_]+)', :get, [:xml, :json] do |id|
  end
  
  endpoint :DirectMessages, '/direct_messages', :get, [:xml, :json, :rss, :atom] do |format|
  end
  
  endpoint :SentDirectMessages, '/direct_messages/sent', :get, [:xml, :json] do |format|
  end
  
  endpoint :SendADirectMessage, '/direct_messages/new', :post, [:xml, :json] do |format|
  end
  
  endpoint :DestroyADirectMessage, '/direct_messages/destroy/(\d+)', [:post, :delete], [:xml, :json] do |id, format|
  end
  
  endpoint :CreateAFriendship, '/friendships/create/([a-zA-Z\d_]+)', :post, [:xml, :json] do |id, format|
  end
  
  endpoint :DestroyAFriendship, '/friendships/destroy/([a-zA-Z\d_]+)', [:post, :delete], [:xml, :json] do |id, format|
  end
  
  endpoint :DoesAFriendshipExist, '/friendships/exists', :get, [:xml, :json] do |format|
  end
  
  endpoint :Login, '/account/verify_credentials', :get, [:xml, :json] do |format|
    render(:login, format.to_s.upcase.to_sym)
  end
  
  endpoint :Logout, '/account/end_session', :post, [:xml, :json] do |format|
    render(:logout, format.to_s.upcase.to_sym)
  end
  
  endpoint :UpdateLocation, '/account/update_location', :post, [:xml, :json] do |format|
  end
    
  endpoint :UpdateDeliveryDevice, '/account/update_delivery_device', :post, [:xml, :json] do |format|
  end

  endpoint :UpdateProfileColors, '/account/update_profile_colors', :post, [:xml, :json] do |format|
  end
    
  endpoint :UpdateProfileImage, '/account/update_profile_image', :post, [:xml, :json] do |format|
  end
  
  endpoint :UpdateProfileBackground, '/account/update_profile_background', :post, [:xml, :json] do |format|
  end
  
  endpoint :WhatsMyRateLimit, '/account/rate_limit_status', :get, [:xml, :json] do |format|
  end
  
  endpoint :Favourites, '/favourites(/[a-zA-Z\d_]+)?', :get, [:xml, :json, :rss, :atom] do |user_or_format, format_or_nil|
  end
  
  endpoint :CreateAFavourite, '/favourites/create/(\d+)', :post, [:xml, :json] do |id, format|
  end
  
  endpoint :DestroyAFavourite, '/favourites/destroy/(\d+)', [:post, :delete], [:xml, :json] do |id, format|
  end
  
  endpoint :Follow, '/notifications/follow/([a-zA-Z\d_]+)', :post, [:xml, :json] do |id, format|
  end
  
  endpoint :Leave, '/notifications/leave/([a-zA-Z\d_]+)', :post, [:xml, :json] do |id, format|
  end
  
  endpoint :CreateABlock, '/blocks/create/([a-zA-Z\d_]+)', :post, [:xml, :json] do |id, format|
  end
  
  endpoint :DestroyABlock, '/blocks/destroy/([a-zA-Z\d_]+)', [:post, :delete], [:xml, :json] do |id, format|
  end
  
  endpoint :TestingTestingOneTwoThree, '/help/test', :get, [:xml, :json] do |format|
  end
  
  endpoint :DowntimeSchedule, '/help/downtime_schedule', :get, [:xml, :json] do |format|
  end
end

# Turn off validation to allow non-XHTML XML
Markaby::Builder.set(:auto_validation, false)
#Markaby::Builder.set(:indent, 2)

module Trikker::Views
  module XML
    def layout
      yield
    end
    def login
      tag!(:authorized) { 'true' }
    end
    def logout
      '<?xml version="1.0" encoding="UTF-8"?>' + 
      tag!(:hash) do
        tag! (:request) {'/account/end_session.xml'}
        tag! (:error) {'Logged out.'}
      end
    end
  end
  
  module JSON
    CONTENT_TYPE = 'application/json; charset=utf-8'
    def layout
      ::JSON.generate(yield)
    end
    def login
      {:authorized => true}
    end
    def logout
      {:request => "/account/end_session.json", :error => "Logged out."}
    end
  end
end