class AdminController < ApplicationController
  def generate
  		require 'open-uri'
		require 'nokogiri'
      	doc = Nokogiri::XML(open("http://www.netflix.com/NewWatchInstantlyRSS"))

      	@instants = doc.xpath('//item').map do |i|
      		{'title' => i.xpath('title').inner_text, 'link' => i.xpath('link').inner_text, 'description' => i.xpath('description').inner_text }
     	end
     	@instants.each do |item|
     		Instant.create(item)
 		end
    	
  end
	def scrape
		require 'open-uri'
		require 'nokogiri'
      	doc = Nokogiri::HTML(open("http://instantwatcher.com/titles/new?view=normal&popups=1&infinite=1"))
      	
      	@instants = doc.css(".title-list-item").map do |i|
      		{'title' => i.at_css(".title-detail-link").text, 'link' => "http://instantwatcher.com" + i.at_css(".title-detail-link")[:href] }
		end
		@instants.each do |item|
			Instant.find_or_create_by_title(item['title']) { |u| u.link = item['link'] }
     		
 		end
	end
end
