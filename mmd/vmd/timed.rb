require 'io_utils'

module MMD; module VMD

	# Base class for records with a frame number, which is pretty much anything really.
	class Timed
		# The frame for which the information is relevant.
		attr_accessor :frame

		# Translates forwards the specified number of frames (backwards if the value is negative.)
		# Raises ArgumentError if the resulting frame offset is negative.
		def translate_frame(frame_offset)
			new_frame = self.frame + frame_offset
			if new_frame < 0
				raise ArgumentError, "Frame offset results in a negative frame number (current frame = #{self.frame}, frame offset = #{frame_offset})"
			end

			self.frame = new_frame
		end
	end

end; end
