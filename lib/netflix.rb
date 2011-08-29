libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'activesupport'
# require 'oauth'
require 'hmac-sha1'
require 'open-uri'
require 'benchmark'
require 'yaml'

require 'lib/netflix/base'
require 'lib/netflix/movie'
require 'lib/netflix/award'
require 'lib/netflix/person'

module Netflix
  class Error < StandardError; end
end

