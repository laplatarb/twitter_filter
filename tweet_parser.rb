require 'eventmachine'
require 'em-http'
require 'em-http/middleware/oauth'
require 'json'
require_relative 'oauth_configuration'

EM.run do

  buffer = ""

  # sign the request with OAuth credentials
  # conn = EventMachine::HttpRequest.new('https://stream.twitter.com/1.1/statuses/sample.json')
  conn = EventMachine::HttpRequest.new('https://stream.twitter.com/1.1/statuses/filter.json')
  conn.use EventMachine::Middleware::OAuth, OAuthConfig

  http = conn.post(body: { track: "ruby" })
  http.callback do
    unless http.response_header.status == 200
      puts "Call failed with response code #{http.response_header.status}"
    end
  end

  http.errback do
    puts "Failed retrieving user stream."
  end

  http.stream do |chunk|
    buffer += chunk
    while line = buffer.slice!(/.+\r\n/)
      tweet = JSON.parse(line)
      urls  = tweet['text'].split.select { |word|  word =~ /http\:\/\// }
      puts tweet['text']
      puts urls
    end
  end
end
