class TwitterSession
  # Both `::get` and `::post` should return the parsed JSON body.
  COMSUMER_KEY = File.read(Rails.root.join('.api_key')).chomp
  CONSUMER_SECRET = File.read(Rails.root.join('.secret_key')).chomp


  def self.get(path, query_values)
    url = Addressable::URI.new(
    :scheme => "https",
    :host => "www.twitter.com",
    :path => path,
    :query_values => query_values
    )

    raw_data = RestClient.get(url)
    parsed_data = JSON.parse(raw_data)
  end

  def self.post(path, req_params)
    url = Addressable::URI.new(
    :scheme => "https",
    :host => "www.twitter.com",
    :path => path
    )

    raw_data = RestClient.post(url, req_params)
    parsed_data = JSON.parse(raw_data)
  end

  def self.access_token
    @access_token ||= TwitterSession.request_access_token
    # Load from file or request from Twitter as necessary. Store token
    # in class instance variable so it is not repeatedly re-read from disk
    # unnecessarily.
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file
    @callback_url = "http://127.0.0.1:3000/oauth/callback"
    @consumer = OAuth::Consumer.new("key","secret", :site => "https://agree2")
    @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
    # session[:request_token] = @request_token
    # redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
    @access_token
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)
    Addressable::URI.new(
    :scheme => "https",
    :host => "www.twitter.com/1.1",
    :path => path.to_s + '.json',
    :query_values => query_values )
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