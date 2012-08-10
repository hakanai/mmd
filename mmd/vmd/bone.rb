require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a bone position.
	class Bone < Timed
		include IOUtils

		attr_accessor :name, :tx, :ty, :tz, :rx, :ry, :rz, :rw, :params

		FORMAT = 'A15 I< eee eeee A64'
		SIZE = 15 + 4 + (4 * 7) + 64

		def data_size; SIZE; end

		def read(io)
			self.name, self.frame, self.tx, self.ty, self.tz, self.rx, self.ry, self.rz, self.rw, self.params = read_packed(io, SIZE, FORMAT)
		end

		def write(io)
			write_packed(io, FORMAT, self.name, self.frame, self.tx, self.ty, self.tz, self.rx, self.ry, self.rz, self.rw, self.params)
		end
	end

end; end
