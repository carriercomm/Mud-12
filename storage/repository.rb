# This class handles serialising and deserialing objects so they can be used the game
# Main jobs:
#
#   Reading objects from their serialised forms and recreating ruby objects from them
#     - From this converting any ids into actual object references
#		  * This functionality should ideally be handles by a subclass which 
#       manages the deserialisation for different storage types (e.g. json, sql)
#
# 	Caching often read objects
#     - Should be a simple queue where used items are put at the front of the queue
#     * Initially, every object in an area should be cached, this may change with 
#       development
#
#   Simple API for getting objects
#     - GetRoom, GetArea, GetID, etc etc
#
#    Simple API for creating objects
#     - CreateRoom, CreateArea, FreeID, etc, etc
#     * IDs should be unique across everything, so free ids should be tracked
class Repository

  # Active objects
  @actives = []

	# Cache
	@cache_size = 0
	@cache   = []
	@cache_ptr = 0

	@@repo = nil

	# Constructor
	def initialize(cache_size)
		@cache, @cache_size, @cache_ptr = [], cache_size, 0
    @actives = []
		@@repo = self
	end

  # Accessor
  def actives
    @actives
  end

  # A nice API for getting objects
	#
	# Arguments:
	#   id: Object id
	def self.get(id)
    obj = @@repo.get_from_cache(id)
    @@repo.actives << obj
    Debug.add("[+ACTIVE] #{id} of type #{obj.class.name}")
    return obj
	end

  # A nice API for saving objects
  #
  # Arguments:
  #   id: Object id
  def self.save(id)
    obj = @@repo.get_active(id)
    @@repo.save_to_storage(obj)
    Debug.add("[-ACTIVE] #{id} of type #{obj.class.name}")
    @@repo.update_cache(id)
  end

  # Gets the Singleton Repo object
	def self.repo
		raise unless !@@repo.nil?
		@@repo
	end


	# Gets an item from the cache, or if not there, gets via storage method
  # Arguments:
	#   id  = Object id
  #
  # Returns:
	#   obj = Object
	def get_from_cache(id)
		
		# Check cache
		obj = nil
		@cache.each{ |o| obj = o if o.id == id }

		# Manage last used first position cache here
		if obj.nil?
			# get from storage if not in the cache
			obj = get_from_storage(id)
			Debug.add("[STORAGE] Got #{id} of type #{obj.class.name}")
      add_to_cache(obj)
		else
			Debug.add("[CACHE] Got #{id} of type #{obj.class.name}")
			shift_in_cache(obj)
		end

		return obj
	end

	# Virtual method - Should be overridden my storage class
	# Gets an object from storage
  # Arguments:
	#   id  = Object id
  #
  # Returns:
	#   obj = Object
	def get_from_storage(id)
		raise "[FATAL] Storage model must be used"
	end

	# Virtual method - Should be overridden my storage class
	# Saves an object to storage
  # Arguments:
	#   obj = Object
	def save_to_storage(obj)
		raise "[FATAL] Storage model must be used"
	end

  # Gets an object from the active list
  def get_active(id)
    obj = @actives.find { |o| o.id == id}
    obj
  end

	# Adds an object to the head of the cache
	def add_to_cache(obj)
		@cache[@cache_ptr] = obj
		@cache_ptr += 1
		@cache_ptr %= @cache_size
	end

	# Moves an object to the head of the cache
	def shift_in_cache(obj)
		ind = @cache.index(obj)
		if ind < @cache_ptr
			@cache_ptr -= 1
			@cache_ptr %= @cache_size
		end
		add_to_cache(obj)
	end

  # Updates cache from the active list and removes from the active list
  def update_cache(id)
    
    # Delete from the active queue
    obj = @actives.find { |i| i.id == id}
    @actives.delete(obj)

    # Update in the cach and place in front
    @cache.collect do |o|
      if o.id == id
        obj
      else
        o
      end
    end
    shift_in_cache(obj)
  end
end

