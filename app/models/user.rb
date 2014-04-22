require 'status'

class User < ActiveRecord::Base
  has_many( :statuses,
            class_name: "Status",
            foreign_key: :twitter_user_id,
            primary_key: :id )

  validates :screen_name, presence: true, uniqueness: true
  validates :twitter_user_id, presence: true, uniqueness: true

  def fetch_statuses!
    Status.fetch_by_twitter_user_id!(self.twitter_user_id)
  end

  def self.fetch_by_screen_name!(screen_name)
    unparsed_user_json = TwitterSession.get("users/show",
                      { :screen_name => screen_name }  )

    User.parse_twitter_user(unparsed_user_json)
  end

  def self.get_by_screen_name(screen_name)
    user = User.find_by_screen_name(screen_name)
    if user.nil?
      user = User.fetch_by_screen_name!(screen_name)
    else
      user
    end
  end

  def self.parse_twitter_user(params)
    parsed_user = JSON.parse(params)

    user_id = parsed_user["id_str"]
    p user_id
    existing_user = User.find_by_twitter_user_id(user_id)
    if existing_user.nil?
      User.create!(:screen_name => parsed_user["screen_name"],
                   :twitter_user_id => parsed_user["id_str"] )
    else
      existing_user.update(user_id)
    end

  end

  def update(screen_name = nil, user_id = nil)
    @screen_name ||= screen_name
    @user_id ||= user_id
    self.save!
  end

end