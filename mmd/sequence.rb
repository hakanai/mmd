require 'mmd/vmd/motion_data'
require 'mmd/wav/wav_writer'

module MMD

	# A sequence of motion data and associated sound data being glued together.
	class Sequence
		
		def initialize
			@pairs = []
		end

		# Adds a pair to the sequence.
		def append(hash)
			input_sound_file = hash[:sound] || (raise ArgumentError, "Missing :sound")
			input_motion_file = hash[:motion] || (raise ArgumentError, "Missing :motion")

			@pairs << Pair.new(input_sound_file, input_motion_file)
		end

		# Outputs the sequence.
		def output(hash)
			output_sound_file = hash[:sound] || (raise ArgumentError, "Missing :sound")
			output_motion_file = hash[:motion] || (raise ArgumentError, "Missing :motion")

			combined_motion = MMD::VMD::MotionData.new
			combined_sound = MMD::WAV::WavWriter.open(output_sound_file)

			frame_offset = 0

			@pairs.each do |pair|
				combined_motion.append(pair.motion, frame_offset)
				combined_sound.append(pair.sound, frame_offset)
				frame_offset += pair.frame_count
			end

			combined_motion.write_file(output_motion_file)
			combined_sound.close
		end

		def close
			@pairs.each { |pair| pair.close }
		end
	end

	# Pairs a VMD file with a WAV.
	class Pair
		attr_accessor :sound
		attr_accessor :motion

		def initialize(sound_file, motion_file)
			@sound = MMD::WAV::WavReader.open(sound_file)
			@motion = MMD::VMD::MotionData.read_file(motion_file)
		end

		# Gets the number of frames covered by this pair. It will either be the number of frames in the sound
		# data or the number of frames in the motion data, whichever of the two is higher.
		def frame_count
			[ @sound.mmd_frame_count, @motion.frame_count + 1 ].max
		end

		def close
			@sound.close
		end
	end
end
