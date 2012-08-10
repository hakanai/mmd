require 'io_utils'

module MMD; module VMD

	# Base class for records with a frame number, which is pretty much anything really.
	class Timed
		# The frame for which the information is relevant.
		attr_accessor :frame
	end

end; end
