require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a bone position.
	class Bone < Timed
		include IOUtils

		attr_accessor :name, :location, :rotation, :interpolation

		FORMAT = 'A15 I< eee eeee A64'
		SIZE = 15 + 4 + (4 * 7) + 64

		def data_size; SIZE; end

		# Reads the bone from the given IO stream.
		def read(io)
			self.name, self.frame, lx, ly, lz, rx, ry, rz, rw, self.interpolation = read_packed(io, SIZE, FORMAT)
			self.location = [lx, ly, lz]
			self.rotation = [rx, ry, rz, rw]
		end

		# Writes the bone to the given IO stream.
		def write(io)
			lx, ly, lz = self.location
			rx, ry, rz, rw = self.rotation
			write_packed(io, FORMAT, self.name, self.frame, lx, ly, lz, rx, ry, rz, rw, self.interpolation)
		end
	end

end; end
