require 'addressable/uri'

class TwitterSession
  # Both `::get` and `::post` should return the parsed JSON body.
  CONSUMER_KEY = File.read(Rails.root.join('.api_key')).chomp
  CONSUMER_SECRET = File.read(Rails.root.join('.secret_key')).chomp

  def self.get(path, query_values)
    @access_token = TwitterSession.access_token

    url = self.path_to_url(path, query_values)

    raw_data = @access_token.get(url).body

    # parsed_data = JSON.parse(raw_data)
  end

  def self.post(path, req_params)
    access_token = self.access_token

    url = self.path_to_url(path)

    raw_data = @access_token.post(url, req_params)
    # parsed_data = JSON.parse(raw_data)
  end

  def self.access_token
    @access_token ||= TwitterSession.request_access_token
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file


    callback_url = "http://127.0.0.1:3000/oauth/callback"
    consumer = OAuth::Consumer.new(CONSUMER_KEY,CONSUMER_SECRET,
                                    :site => "https://api.twitter.com")
    request_token = consumer.get_request_token

    # session[:request_token] = request_token
    authorize_url = request_token.authorize_url(:oauth_callback => callback_url)

    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )

    access_token
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)
    Addressable::URI.new(
    :scheme => "https",
    :host => "api.twitter.com",
    :path => '1.1/' + path.to_s + '.json',
    :query_values => query_values ).to_s
  end
end

# TwitterSession.get(
#   "statuses/user_timeline",
#   { :user_id => "737657064" }
# )
# TwitterSession.post(
#   "statuses/update",
#   { :status => "New Status!" }
# )