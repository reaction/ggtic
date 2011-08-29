class Instant < ActiveRecord::Base
	has_many :recommendations
	scope :recommend, Instant.joins(:recommendations)
	#.where('recommendations.recommended' => 'The Gentlemens Guide To Midnite Cinema')
  	
end
