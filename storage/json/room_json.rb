#!/usr/bin/env ruby

# JSON storage functions
class Room

	# Create the constructor JSON can work with
	attr_serialise :id, :name, :desc, :flags, :items, :mobs, :players
	# Can't use the automatic ones here due for flexibility needed
	def to_json(*a)
		{
			'json_class' 		=>	self.class.name,
			'id'						=>	@id,
			'name'					=> 	@name,
			'desc'					=> 	@desc,
			'flags'					=> 	@flags,
			'items'					=>	@items.collect { |i| i.id },
			'mobs'					=>	@mobs.collect { |m| m.id },
			'players'				=>	@players.collect { |p| p.id },
		}.to_json(*a)
	end

	def self.json_create(o)
		new(*o['id'], *o['name'], *o['desc'], *o['flags'], *o['items'], *o['mobs'], *o['players'])
	end
end
