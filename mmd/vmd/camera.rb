require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a camera position.
	class Camera < Timed
		include IOUtils

		attr_accessor :length, :location, :rotation, :interpolation, :viewing_angle, :perspective

		FORMAT = 'I< e eee eee A24 I< C'
		SIZE = 4 + 4 + (4 * 3) + (4 * 3) + 24 + 4 + 1

		def data_size; SIZE; end

		# Reads the camera from the given IO stream.
		def read(io)
			self.frame, self.length, lx, ly, lz, rx, ry, rz, self.interpolation, self.viewing_angle, self.perspective = read_packed(io, SIZE, FORMAT)
			self.location = [lx, ly, lz]
			self.rotation = [rx, ry, rz]
		end

		# Writes the camera to the given IO stream.
		def write(io)
			lx, ly, lz = self.location
			rx, ry, rz = self.rotation
			write_packed(io, FORMAT, self.frame, self.length, lx, ly, lz, rx, ry, rz, self.interpolation, self.viewing_angle, self.perspective)
		end
	end

end; end
