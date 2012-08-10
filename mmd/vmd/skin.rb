require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a skin (primarily seems to be used to change facial expressions.)
	class Skin < Timed
		include IOUtils

		attr_accessor :name, :weight

		FORMAT = 'A15 I< e'
		SIZE = 15 + 4 + 4

		def data_size; SIZE; end

		# Reads the skin from the given IO stream.
		def read(io)
			self.name, self.frame, self.weight = read_packed(io, SIZE, FORMAT)
		end

		# Writes the skin to the given IO stream.
		def write(io)
			write_packed(io, FORMAT, self.name, self.frame, self.weight)
		end
	end

end; end
