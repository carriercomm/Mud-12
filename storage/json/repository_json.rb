# This handles all of the JSON deserialisation and storage methods
#
# 1. Should manage where the data directory is (THIS SHOULD BE SET BY THE CONFIGURATION)
#
# 2. Should retreive files from the data directory and deserialise them.
#    - Some objects may require their dependencies deserialised too
class Repository

	# Static methods needed i.e. storage dir
	class << self
		attr_accessor :data_dir
	end

	# Overloaded method from repository
	# Gets an object from storage
	# Arguments:
	#   id = Object id
	# Returns:
	#   obj = Object
	def get_from_storage(id)
		raise "[FATAL] Storage directory not set" if Repository.data_dir.nil?

		# Aquire raw JSON
		raw = aquire_raw(id)

		# Create object
		obj = JSON::parse(raw)

		# Grab needed objects, args => self
		obj.cache_collect

		# return
		return obj
	end

	# Overloaded method from repository
	# Saves an object to storage
	# Arguments:
	#   id = Object id
	def save_to_storage(obj)
		raise "[FATAL] Storage directory not set" if Repository.data_dir.nil?

		write_raw(obj)
	end


private

  # Given an object, write out the json file
  def write_raw(obj)

    # To write
    raw_data = obj.to_json

    # File name
    file_name = "#{Repository.data_dir}#{obj.id}.json"

    File.open(file_name, 'w') do |f|
      f.puts(raw_data)
    end
  end

	# Given that data files are stored {datadir}/{id}.json, retrieve that file or fail
	def aquire_raw(id)
		
		# To return
		raw_data = nil

		# file name
		file_name = "#{Repository.data_dir}#{id}.json"

    # Does the file exist?
		if File.exists?(file_name)

			# Open the file and process
			File.open(file_name, 'r') do |f|

				# Read all the data
				raw_data = ""
				f.each_line { |line| raw_data << line }
			end
		else

			# If it doesn't exist, warn the server and return nil - effectively removing the object
			Debug.add("[WARNING] #{id}.json not found")
		end

		return raw_data
	end
end
