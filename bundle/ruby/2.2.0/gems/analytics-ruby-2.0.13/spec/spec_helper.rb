require 'segment/analytics'
require 'wrong'
require 'active_support/time'

include Wrong

# Setting timezone for ActiveSupport::TimeWithZone to UTC
Time.zone = 'UTC'

module Segment
  class Analytics
    WRITE_KEY = 'testsecret'

    TRACK = {
      :event => 'Ruby Library test event',
      :properties => {
        :type => 'Chocolate',
        :is_a_lie => true,
        :layers => 20,
        :created =>  Time.new
      }
    }

    IDENTIFY =  {
      :traits => {
        :likes_animals => true,
        :instrument => 'Guitar',
        :age => 25
      }
    }

    ALIAS = {
      :previous_id => 1234,
      :user_id => 'abcd'
    }

    GROUP = {}

    PAGE = {
      :name => 'home'
    }

    SCREEN = {
      :name => 'main'
    }

    USER_ID = 1234
    GROUP_ID = 1234

    # Hashes sent to the client, snake_case
    module Queued
      TRACK = TRACK.merge :user_id => USER_ID
      IDENTIFY = IDENTIFY.merge :user_id => USER_ID
      GROUP = GROUP.merge :group_id => GROUP_ID, :user_id => USER_ID
      PAGE = PAGE.merge :user_id => USER_ID
      SCREEN = SCREEN.merge :user_id => USER_ID
    end

    # Hashes which are sent from the worker, camel_cased
    module Requested
      TRACK = TRACK.merge({
        :userId => USER_ID,
        :type => 'track'
      })

      IDENTIFY = IDENTIFY.merge({
        :userId => USER_ID,
        :type => 'identify'
      })

      GROUP = GROUP.merge({
        :groupId => GROUP_ID,
        :userId => USER_ID,
        :type => 'group'
      })

      PAGE = PAGE.merge :userId => USER_ID
      SCREEN = SCREEN.merge :userId => USER_ID
    end
  end
end
