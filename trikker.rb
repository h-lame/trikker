#!ruby
#!/usr/local/bin/ruby -rubygems
require 'camping'

Camping.goes :Trikker

module Trikker::Controllers
  class Timelines < R '/statuses/(public|friends|user)_timeline\.(xml|json|rss|atom)'
    def get(timeline_type, format)
    end
  end
  
  class StatusUpdate < R '/statues/update\.(xml|json)'
    def post(format)
    end
  end
  
  class ShowAStatus < R '/statuses/show/(\d+)\.(xml|json)'  
    def get(id, format)
    end
  end
    
  class StatusReplies < R '/statuses/replies\.(xml|json|rss|atom)'
    def get(format)
    end
  end
  
  class StatusFriendsAndFollowers < R '/statuses/(friends|followers)\.(xml|json)'
    def get(friend_or_follower, format)
    end
  end
  
  class DestroyAStatus < R '/statuses/destroy/(\d+)\.(xml|json)'
    def post(id, format)
    end
    def delete(id, format)
    end
  end
  
  class ShowAUser < R '/users/show/([a-ZA-Z\d_]+)\.(xml|json)'
    # NOTE - technically /users/show.xml?email=blah@blah.com is valid too...
    def get(id)
    end
  end
  
  class DirectMessages < R '/direct_messages\.(xml|json|rss|atom)'
    def get(format)
    end
  end
  
  class SentDirectMessages < R '/direct_messages/sent\.(xml|json)'
    def get(format)
    end
  end
  
  class SendADirectMessage < R '/direct_messages/new\.(xml|json)'
    def post(format)
    end
  end
  
  class DestroyADirectMessage < R '/direct_messages/destroy/(\d+)\.(xml|json)'
    def post(id, format)
    end
    def delete(id, format)
    end
  end
  
  class CreateAFriendship < R '/friendships/create/([a-ZA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
  end
  
  class DestroyAFriendship < R '/friendships/destroy/([a-ZA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
    
    def delete(id, format)
    end
  end
  
  class DoesAFriendshipExist < R '/friendships/exists\.(xml|json)'
    def get(format)
    end
  end
  
  class Login < R '/account/verify_credentials\.(xml|json)'
    def get(format)
    end
  end
  
  class Logout < R '/account/end_session\.(xml|json)'
    def post(format)
    end
  end
  
  class UpdateLocation < R '/account/update_location\.(xml|json)'
    def post(format)
    end
  end
    
  class UpdateDeliveryDevice < R '/account/update_delivery_device\.(xml|json)'
    def post(format)
    end
  end

  class UpdateProfileColors < R '/account/update_profile_colors\.(xml|json)'
    def post(format)
    end
  end
    
  class UpdateProfileImage < R '/account/update_profile_image\.(xml|json)'
    def post(format)
    end
  end
  
  class UpdateProfileBackground < R '/account/update_profile_background\.(xml|json)'
    def post(format)
    end
  end
  
  class WhatsMyRateLimit < R '/account/rate_limit_status\.(xml|json)'
    def get(format)
    end
  end
  
  class Favourites < R '/favourites(/[a-zA-Z\d_]+)?\.(xml|json|rss|atom)/'
    def get(user_or_format, format_or_nil)
    end
  end
  
  class CreateAFavourite < R '/favourites/create/(\d+)\.(xml|json)'
    def post(id, format)
    end
  end
  
  class DestroyAFavourite < R '/favourites/destroy/(\d+)\.(xml|json)'
    def post(id, format)
    end
    def delete(id, format)
    end
  end
  
  class Follow < R '/notifications/follow/([a-zA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
  end
  
  class Leave < R '/notifications/leave/([a-zA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
  end
  
  class CreateABlock < R '/blocks/create/([a-zA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
  end
  
  class DestroyABlock < R '/blocks/destroy/([a-zA-Z\d_]+)\.(xml|json)'
    def post(id, format)
    end
    def delete(id, format)
    end
  end
  
  class TestingTestingOneTwoThree < R '/help/test\.(xml|json)'
    def get(format)
    end
  end
  
  class DowntimeSchedule < R '/help/downtime_schedule\.(xml|json)'
    def get(format)
    end
  end
end