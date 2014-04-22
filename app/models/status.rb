class Status < ActiveRecord::Base
  validates :body, :twitter_status_id, :twitter_user_id, presence: true
  validates :twitter_status_id, uniqueness: true

  def self.fetch_by_twitter_user_id!(twitter_user_id)
    TwitterSession.get(
      "statuses/user_timeline",
      { :user_id => "twitter_user_id" }
    )
  end

  def self.parse_json(params)
    parsed_data = JSON.parse(params)

    Status.new(:body => ,
    :twitter_status_id => ,
    :twitter_user_id => )
  end
end