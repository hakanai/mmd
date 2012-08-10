require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a light colour and position.
	class Light < Timed
		include IOUtils

		attr_accessor :rgb, :location

		FORMAT = 'I< eee eee'
		SIZE = 4 + (4 * 3) + (4 * 3)

		def data_size; SIZE; end

		# Reads the light from the given IO stream.
		def read(io)
			self.frame, r, g, b, lx, ly, lz = read_packed(io, SIZE, FORMAT)
			self.rgb = [r, g, b]
			self.location = [lx, ly, lz]
		end

		# Writes the light to the given IO stream.
		def write(io)
			r, g, b = self.rgb
			lx, ly, lz = self.location
			write_packed(io, FORMAT, self.frame, r, g, b, lx, ly, lz)
		end
	end

end; end
