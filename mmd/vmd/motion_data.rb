require 'io_utils'
require 'mmd/vmd/bone'
require 'mmd/vmd/skin'
require 'mmd/vmd/camera'
require 'mmd/vmd/light'

module MMD; module VMD

	# Representation of a motion data file.
	# Reference: http://blog.goo.ne.jp/torisu_tetosuki/e/bc9f1c4d597341b394bd02b64597499d
	class MotionData
		include IOUtils

		# The magic number heading the file.
		attr_accessor :magic

		# The name of the model the motion data was written for. It doesn't necessarily have to match the model you're going to use
		# if the bone names of the models match up.
		attr_accessor :model_name

		# The bone array. Each element specifies the position of one bone for one frame.
		attr_accessor :bones

		# The skin array. Each element specifies the skin to use for one frame.
		attr_accessor :skins

		# The camera array. Each element specifies the camera position for one frame.
		attr_accessor :cameras

		# The light array. Each element specifies the colour and position of a light for one frame.
		attr_accessor :lights

		HEADER_FORMAT = 'A30 Z20'
		HEADER_SIZE = 30 + 20

		COUNT_FORMAT = 'I<'
		COUNT_SIZE = 4

		def initialize
			self.bones = []
			self.skins = []
			self.cameras = []
			self.lights = []
		end
		
		# Convenience method to create a new MotionData, reading the data from the specified file.
		# Returns the MotionData with everything loaded.
		def self.read_file(file)
			File.open(file, 'r') do |io|
				motion_data = new
				motion_data.read(io)
				motion_data
			end
		end

		# Reads motion data from the given IO stream.
		def read(io)
			self.magic, self.model_name = read_packed(io, HEADER_SIZE, HEADER_FORMAT)

			#TODO: I think there is a 0001 version of the format with "Vocaloid Motion Data File" or similar, but I have never seen such a file.
			# I guess if I end up implementing that format, I will split the reading code into separate classes for each.
			#TODO: Some files just say "Vocaloid Motion Data 0002" while others say "Vocaloid Motion Data 0002JKLM" (there might be a null before the J.)
			if magic !~ /^Vocaloid Motion Data 0002/
				raise IOError.new("Not Vocaloid Motion Data: #{magic}")
			end

			# People say it's Shift_JIS but since it's a Windows application I am going to bet that it's really windows-31j.
			self.model_name.force_encoding('windows-31j')

			bone_count = read_packed(io, COUNT_SIZE, COUNT_FORMAT)[0]
			(0...bone_count).each do |i|
				bone = MMD::VMD::Bone.new
				bone.read(io)
				self.bones << bone
			end

			skin_count = read_packed(io, COUNT_SIZE, COUNT_FORMAT)[0]
			(0...skin_count).each do |i|
				skin = MMD::VMD::Skin.new
				skin.read(io)
				self.skins << skin
			end

			# At this point, various sites say there is a camera array, light array and self shadow array, in a similar format.
			# What I see in my files though, is the next 4 bytes being 0 and the 4 bytes after that being the max frame number.
			# One day I might figure out what is going on. Until then, I will leave it out.
			#
			# I get the feeling that files which are "Vocaloid Motion Data 0002JKLM" have a different format.
			# Google has zero hits on this string. What the hell?

			if magic == 'Vocaloid Motion Data 0002'
				camera_count = read_packed(io, COUNT_SIZE, COUNT_FORMAT)[0]
				(0...camera_count).each do |i|
					camera = MMD::VMD::Camera.new
					camera.read(io)
					self.cameras << camera
				end

				light_count = read_packed(io, COUNT_SIZE, COUNT_FORMAT)[0]
				(0...light_count).each do |i|
					light = MMD::VMD::Light.new
					light.read(io)
					self.lights << light
				end

				# Supposedly there is this too, but I'm not seeing it on files with this magic.
				#self_shadow_count = read_packed(io, COUNT_SIZE, COUNT_FORMAT)[0]
				#puts "self_shadow_count = #{self_shadow_count}"
				
			end


			#self_shadow_count, _ = read_packed(io, 4, "I<")
			#pos += 4
			#puts "Number of self shadows: #{self_shadow_count}"

			#(0..self_shadow_count).each do |i|
				#raise "Haven't seen this yet, so cowardly failing"
				#struct VMD_SELF_SHADOW { // 9 Bytes // セルフシャドー
				#DWORD FlameNo;
				#BYTE Mode; // 00-02
				#float Distance; // 0.1 - (dist * 0.00001)
				#} vmd_self_shadow;
			#end
		end

		# Convenience method to write the motion data out to a file.
		def write_file(file)
			File.open(file, 'w') do |io|
				write(io)
			end
		end

		# Writes motion data to the given IO stream.
		def write(io)
			# We don't support the new format so I guess we better use the 0002 magic and not whatever the file had in it.
			write_packed(io, HEADER_FORMAT, "Vocaloid Motion Data 0002\0\0\0\0\0", self.model_name)

			write_packed(io, COUNT_FORMAT, self.bones.size)
			self.bones.each do |bone|
				bone.write(io)
			end

			write_packed(io, COUNT_FORMAT, self.skins.size)
			self.skins.each do |skin|
				skin.write(io)
			end

			write_packed(io, COUNT_FORMAT, self.cameras.size)
			self.cameras.each do |camera|
				camera.write(io)
			end

			write_packed(io, COUNT_FORMAT, self.lights.size)
			self.lights.each do |light|
				light.write(io)
			end
		end

		# Returns an array containing all timed records.
		def all_timed_records
			self.bones + self.skins + self.cameras + self.lights
		end

		# Computes the first frame for the sequence. Generally this would be 0 because animations tend to have the initial position data at frame 0.
		def first_frame
			self.all_timed_records.map { |r| r.frame }.min
		end

		# Computes the last frame for the sequence. The start frame is presumed to be 0.
		# I could cache it, but if someone pokes a frame value directly from the record it's on, I wouldn't know to recompute it at the moment.
		def last_frame
			self.all_timed_records.map { |r| r.frame }.max
		end

		# Computes the frame count. This is just one more than the last frame, since the sequence includes a frame 0.
		def frame_count
			self.last_frame + 1
		end

		# Translates all motion data forwards by the specified number of frames (backwards if the value is negative.)
		# Raises ArgumentError if the resulting frame offset would be negative.
		def translate_frames(frame_offset)
			# Up-front check for sanity.
			if self.first_frame + frame_offset < 0
				raise ArgumentError, "Frame offset results in a negative frame number (first frame = #{self.first_frame}, frame offset = #{frame_offset})"
			end

			self.all_timed_records.each { |r| r.translate_frame(frame_offset) }
		end

		# Appends the specified motion data.
		# The frame offsets are not modified automatically so if you want to translate that, use translate_frames first.
		def append(motion_data, offset)
			offset_motion_data = motion_data.clone
			offset_motion_data.translate_frames(offset)

			self.bones += offset_motion_data.bones
			self.skins += offset_motion_data.skins
			self.cameras += offset_motion_data.cameras
			self.lights += offset_motion_data.lights
		end

		def clone
			cloned = super
			cloned.bones = cloned.bones.clone
			cloned.skins = cloned.skins.clone
			cloned.cameras = cloned.cameras.clone
			cloned.lights = cloned.lights.clone
			cloned
		end
	end

end; end

