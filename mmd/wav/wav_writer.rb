require 'io_utils'

module MMD; module WAV

	class WavWriter
		include IOUtils

		BYTES_PER_SECOND = 176400
		FRAMES_PER_SECOND = 30
		BYTES_PER_FRAME = BYTES_PER_SECOND / FRAMES_PER_SECOND

		def initialize(io)
			@io = io
			@data_size = 0

			write_riff_header
			write_wave_header
			write_data_header
		end

		# Copies data from the given wav.
		#  wav    - a WavReader with the data to copy in.
		#  offset - the offset in MMD frames to insert the new data.
		def append(wav, offset)
			wav.seek_to_data
			@io.seek(@data_offset + (BYTES_PER_FRAME * offset))
			while buf = wav.read(BYTES_PER_SECOND)
				@data_size += buf.size
				@io.write(buf)
			end
		end

		def close
			# Fill in the values we left as zero earlier since we didn't know the size.

			@io.seek(@data_chunk_size_offset)
			write_packed(@io, 'I<', @data_size)

			@io.seek(@riff_chunk_size_offset)
			write_packed(@io, 'I<', 4 + 8 + 16 + 8 + @data_size)

			@io.close
		end

		def self.open(file, &block)
			wav = new(File.open(file, 'w'))
			if block
				block.call(wav)
				wav.close
			else
				wav
			end
		end

		private

		def write_riff_header
			@riff_chunk_size_offset = @io.pos + 4

			chunk_id = 'RIFF'
			chunk_size = 0 # will fill in later
			format = 'WAVE'
			write_packed(@io, 'Z4 I< Z4', chunk_id, chunk_size, format)
		end

		def write_wave_header
			chunk_id = 'fmt '
			chunk_size = 16
			audio_format = 1
			channel_count = 2
			sample_rate = 44100
			byte_rate = 176400
			block_align = 4
			bits_per_sample = 16
			write_packed(@io, 'Z4 I< S< S< I< I< S< S<', chunk_id, chunk_size, audio_format, channel_count, sample_rate, byte_rate, block_align, bits_per_sample)
		end

		def write_data_header
			@data_chunk_size_offset = @io.pos + 4

			chunk_id = 'data'
			chunk_size = 0 # will fill in later
			write_packed(@io, 'Z4 I<', chunk_id, chunk_size)

			@data_offset = @io.pos
		end

	end

end; end
