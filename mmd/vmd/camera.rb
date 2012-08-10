require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a camera position.
	class Camera < Timed
		include IOUtils

		attr_accessor :length, :lx, :ly, :lz, :rx, :ry, :rz, :interpolation, :viewing_angle, :perspective

		FORMAT = 'I< e eee eee A24 I< C'
		SIZE = 4 + 4 + (4 * 3) + (4 * 3) + 24 + 4 + 1

		def data_size; SIZE; end

		def read(io)
			self.frame, self.length, self.lx, self.ly, self.lz, self.rx, self.ry, self.rz, self.interpolation, self.viewing_angle, self.perspective = read_packed(io, SIZE, FORMAT)
		end

		def write(io)
			write_packed(io, FORMAT, self.frame, self.length, self.lx, self.ly, self.lz, self.rx, self.ry, self.rz, self.interpolation, self.viewing_angle, self.perspective)
		end
	end

end; end
