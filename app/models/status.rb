require 'open-uri'
require 'user'

class Status < ActiveRecord::Base
  belongs_to( :user,
              class_name: "User",
              foreign_key: :twitter_user_id,
              primary_key: :id )

  validates :body, :twitter_status_id, :twitter_user_id, presence: true
  validates :twitter_status_id, uniqueness: true

  def self.fetch_by_twitter_user_id!(twitter_user_id)
    p twitter_user_id

    unparsed_statuses = TwitterSession.get("statuses/user_timeline",
                      :user_id => twitter_user_id )

    parsed_statuses = Status.parse_json(unparsed_statuses)

    p parsed_statuses

    Status.where(:twitter_user_id => twitter_user_id)
  end

  def self.post(body)
    posted_tweet = TwitterSession.post("statuses/update",
                    { :status => body } )

    begin
      Status.parse_json(posted_tweet)
    rescue => e
      # puts "Error: #{posted_tweet.to_json[:errors].first[:message]}"
      puts "Tweet already exists!"
    end

  end

  def self.get_by_twitter_user_id(user_id)
    if internet_connection?
      fetch_by_twitter_user_id!(user_id)
    else
      Status.where(:twitter_user_id => user_id)
    end
  end


  def self.parse_json(params)
    parsed_data = JSON.parse(params)

    statuses = parsed_data.map do |status_hash|
      body = status_hash["text"]
      tweet_id = status_hash["id_str"]
      user_id = status_hash["user"]["id_str"]

      Status.new(:body => body,
      :twitter_status_id => tweet_id,
      :twitter_user_id => user_id)
    end

    p statuses

    old_ids = Status.pluck(:twitter_status_id)

    new_statuses = statuses.select do |status|
      not old_ids.include?( status.twitter_status_id )
    end

    new_statuses.each { |new_status| new_status.save! }
  end

  def self.internet_connection?
    begin
      true if open("http://www.google.com/")
    rescue
      false
    end
  end

end