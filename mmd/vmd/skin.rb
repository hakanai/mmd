require 'io_utils'
require 'mmd/vmd/timed'

module MMD; module VMD

	# Record indicating a skin (primarily seems to be used to change facial expressions.)
	class Skin < Timed
		include IOUtils

		attr_accessor :name, :value

		FORMAT = 'A15 I< e'
		SIZE = 15 + 4 + 4

		def data_size; SIZE; end

		def read(io)
			self.name, self.frame, self.value = read_packed(io, SIZE, FORMAT)
		end

		def write(io)
			write_packed(io, FORMAT, self.name, self.frame, self.value)
		end
	end

end; end
