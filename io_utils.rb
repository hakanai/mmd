
module IOUtils
	# Convenience method to read a packed string.
	# TODO: Is there no convenient way to figure out the length from the format?
	def read_packed(io, len, format)
		io.read(len).unpack(format)
	end

	# Convenience method to write a packed string.
	def write_packed(io, format, *values)
		io.write(values.pack(format))
	end
end
