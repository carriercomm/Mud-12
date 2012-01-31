#!/usr/bin/env ruby
require './template.rb'

# A template for a mob in the game
class MobTemplate < Template

	# max_health	-> template max health
	attr_accessor :max_health

	# default constructor
	def initialize(id, name, desc, max_health)
		super(id, name, desc)
		@max_health = max_health
	end
end
