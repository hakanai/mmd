require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a light colour and position.
	class Light < Timed
		include IOUtils

		attr_accessor :r, :g, :b, :lx, :ly, :lz

		FORMAT = 'I< eee eee'
		SIZE = 4 + (4 * 3) + (4 * 3)

		def data_size; SIZE; end

		def read(io)
			self.frame, self.r, self.g, self.b, self.lx, self.ly, self.lz = read_packed(io, SIZE, FORMAT)
		end

		def write(io)
			write_packed(io, FORMAT, self.frame, self.r, self.g, self.b, self.lx, self.ly, self.lz)
		end
	end

end; end
