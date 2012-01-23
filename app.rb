# encoding: utf-8

require 'bundler/setup'
Bundler.require
require 'uri'
require 'active_support/cache'

set :erubis, :escape_html => true

INSTAPAPER = Instapi.new(ENV['INSTAPAPER_USERNAME'], ENV['INSTAPAPER_PASSWORD'])
CACHE = ActiveSupport::Cache.lookup_store(:dalli_store)

def text(url)
  if result = CACHE.read(url)
    puts "use cache for: #{url}"
    result
  else
    result = INSTAPAPER.text(URI.encode(url))
    CACHE.write(url, result)
    result
  end
end

get '/' do
  @bookmarks = INSTAPAPER.unread
  erubis :index
end

get '/t' do
  @url = params[:url]
  @text = text(@url)
  erubis :text
end
