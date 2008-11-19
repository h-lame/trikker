#!ruby
#!/usr/local/bin/ruby -rubygems
require 'rubygems'

gem 'camping'
gem 'reststop'
gem 'json'

require 'camping'
require 'camping/db'
require 'basic_authentication'
require 'reststop'
require 'json'

Camping.goes :Trikker

require 'active_record'
require 'active_record/serializers/xml_serializer'

ActiveRecord::XmlSerializer.class_eval do
  def dasherize?
    false
  end
  
  def root
    @record.class.to_s.underscore.split('/').last 
  end
end

ActiveRecord::XmlSerializer::Attribute.class_eval do
  def decorations(include_types = true)
    {}
  end
end

module Trikker
  include Camping::BasicAuth
  def self.authenticate(u, p)
    @logged_in_as = Models::User.find_by_screen_name_and_password(u,p)
    !@logged_in_as.nil?
  end
end

module Trikker::Models
  class User < Base
    belongs_to :user
    has_many :statuses
    has_many :followings, :class_name => 'Trikker::Models::Friendship', :foreign_key => 'follower_id'
    has_many :friendships, :class_name => 'Trikker::Models::Friendship', :foreign_key => 'friend_id'
    has_many :favourites
  end
  class Status < Base
    belongs_to :user
    belongs_to :reply_to_status, :class_name => 'Trikker::Models::Status', :foreign_key => 'in_reply_to_status_id'
    belongs_to :reply_to_user, :class_name => 'Trikker::Models::User', :foreign_key => 'in_reply_to_user_id'
  end
  class Friendship< Base
    belongs_to :friend, :class_name => 'Trikker::Models::User', :foreign_key => 'friend_id'
    belongs_to :follower, :class_name => 'Trikker::Models::User', :foreign_key => 'follower_id'
  end
  class Favourite< Base
    belongs_to :user
    belongs_to :status
  end

  class CreateTheBasics < V 1.0
    def self.up
      create_table :trikker_users do |t|
        t.string :name, :screen_name, :null => false
        t.string :location, :profile_image_url, :url
        t.string :description, :limit => 160
        t.boolean :protected, :null => false, :default => false
        t.string :profile_background_color, :profile_sidebar_fill_color, :default => 'FFFFFF', :null => false, :limit => 6
        t.string :profile_text_color, :profile_link_color, :profile_sidebar_border_color, :default => '000000', :null => false, :limit => 6
        t.time :created_at
       	t.string :profile_background_image_url
        t.boolean :profile_background_tile
        t.string :password
      end
      create_table :trikker_statuses do |t|
        t.time :created_at, :null => false
        t.string :text, :null => false, :limit => 140
        t.string :source
        t.boolean :truncated
        t.integer :in_reply_to_status_id, :in_reply_to_user_id
      end
      create_table :trikker_friendships do |t|
        t.integer :friend_id, :follower_id, :null => false
      end
      create_table :trikker_favourites do |t|
        t.integer :user_id, :status_id, :null => false
      end
    end
    def self.down
      drop_table :trikker_favourites
      drop_table :trikker_friendships
      drop_table :trikker_statuses
      drop_table :trikker_users
    end
  end
end


module Trikker::Controllers
  def self.endpoint(controller_name, routes, methods, formats, &blck)
    formats = [*formats]
    formats_are_optional = formats.delete(:optional)
    f = "\.(#{formats.join('|')})"
    f = "(#{f})?" unless formats_are_optional.nil?
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
  endpoint :ShowAUser, '/users/show/([a-zA-Z\d_]+)', :get, [:xml, :json] do |screen_name_or_user_id, format|
    @user = Trikker::Models::User.find_by_screen_name(screen_name_or_user_id) || Trikker::Models::User.find_by_id(screen_name_or_user_id)
    render(:user, format.to_s.upcase.to_sym)
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
  
  endpoint :Login, '/account/verify_credentials', :get, [:optional, :xml, :json] do |_, format|
    format = :HTML if format.nil?
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
  module HTML
    def login
      'Authorized'
    end
  end
  
  module XML
    def layout
      yield
    end
    def login
      tag!(:authorized) { 'true' }
    end
    def logout
      instruct!
      tag!(:hash) do
        tag! (:request) {'/account/end_session.xml'}
        tag! (:error) {'Logged out.'}
      end
    end
    def user
      @user.to_xml(:except => :password)
    end
  end
  
  module JSON
    CONTENT_TYPE = 'application/json; charset=utf-8'
    def layout
      yield
    end
    def login
      ::JSON.generate({:authorized => true})
    end
    def logout
      ::JSON.generate({:request => "/account/end_session.json", :error => "Logged out."})
    end
    def user
      @user.to_json
    end
  end
end

def Trikker.create
  Camping::Models::Session.create_schema
  Trikker::Models.create_schema :assume => (Trikker::Models::User.table_exists? ? 1.0 : 0.0)
end
