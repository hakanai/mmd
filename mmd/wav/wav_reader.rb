require 'io_utils'

module MMD; module WAV

	class WavReader
		include IOUtils

		# The number of MMD frames which would be required to completely cover the audio.
		attr_reader :mmd_frame_count

		def initialize(io)
			@io = io

			read_riff_header
			read_wave_header
			read_data_header
		end

		def seek_to_data
			@io.seek(@data_start)
		end

		def read(bytes)
			@io.read(bytes)
		end

		def self.open(file, &block)
			wav = new(File.open(file, 'r'))
			if block
				block.call(wav)
				wav.close
			else
				wav
			end
		end

		def close
			@io.close
		end

		private

		def read_riff_header
			chunk_id = read_packed(@io, 4, 'Z4')[0]
			if chunk_id != 'RIFF'
				raise ArgumentError, "Not a RIFF file"
			end

			chunk_size = read_packed(@io, 4, 'I<')[0]

			format = read_packed(@io, 4, 'Z4')[0]
			if format != 'WAVE'
				raise ArgumentError, "Not a WAVE file"
			end
		end

		def read_wave_header
			chunk_id = read_packed(@io, 4, 'Z4')[0]
			if chunk_id != 'fmt '
				raise ArgumentError, "Not a format chunk: #{chunk_id}"
			end

			chunk_size = read_packed(@io, 4, 'I<')[0]

			audio_format, channel_count, sample_rate, byte_rate, block_align, bits_per_sample, _ = read_packed(@io, chunk_size, 'S< S< I< I< S< S< Z*')
			if audio_format != 1
				raise ArgumentError, "Only PCM WAVE files are supported at the moment"
			end
			if channel_count != 2
				raise ArgumentError, "Only stereo is supported at the moment"
			end
			if sample_rate != 44100
				raise ArgumentError, "Only 44.1kHz is supported at the moment"
			end
			if bits_per_sample != 16
				raise ArgumentError, "Only 16-bit is supported at the moment"
			end

			@channel_count = channel_count
			@sample_rate = sample_rate
			@bits_per_sample = bits_per_sample
		end

		def read_data_header
			chunk_id = read_packed(@io, 4, 'Z4')[0]
			while chunk_id != 'data'
				chunk_size = read_packed(@io, 4, 'I<')[0]
				@io.seek(chunk_size, IO::SEEK_CUR)
				chunk_id = read_packed(@io, 4, 'Z4')[0]
			end

			chunk_size = read_packed(@io, 4, 'I<')[0]
			bytes_per_sample = (@bits_per_sample * @channel_count) / 8
			sample_count = chunk_size / bytes_per_sample
			samples_per_mmd_frame = @sample_rate / 30

			@data_start = @io.pos
			@mmd_frame_count = (sample_count / samples_per_mmd_frame).ceil
		end
	end

end; end
