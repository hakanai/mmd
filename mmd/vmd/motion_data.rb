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

		HEADER_FORMAT = 'A30 A20'
		HEADER_SIZE = 30 + 20

		COUNT_FORMAT = 'I<'
		COUNT_SIZE = 4

		def read(io)
			self.magic, self.model_name = read_packed(io, HEADER_SIZE, 'A30 Z20')

			#TODO: I think there is a 0001 version of the format with "Vocaloid Motion Data File" or similar, but I have never seen such a file.
			# I guess if I end up implementing that format, I will split the reading code into separate classes for each.
			#TODO: Some files just say "Vocaloid Motion Data 0002" while others say "Vocaloid Motion Data 0002JKLM".
			if magic !~ /^Vocaloid Motion Data 0002/
				raise IOError.new("Not Vocaloid Motion Data: #{magic}")
			end

			# People say it's Shift_JIS but since it's a Windows application I am going to bet that it's really windows-31j.
			self.model_name.force_encoding('windows-31j')

			self.bones = []
			self.skins = []
			self.cameras = []
			self.lights = []

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

		def write(io)
			# We don't support the new format so I guess we better use the 0002 magic and not whatever the file had in it.
			write_packed(io, HEADER_FORMAT, 'Vocaloid Motion Data 0002', self.model_name)

			write_packed(io, COUNT_FORMAT, self.bones.size)
			self.bones.each do |bone|
				bone.write(io)
			end

			write_packed(io, COUNT_FORMAT, self.skins.size)
			self.skins.each do |skin|
				skin.write(io)
			end

			# End with the zero count which are supposedly at the end of the file.
			write_packed(io, COUNT_SIZE, COUNT_FORMAT, 0)
			write_packed(io, COUNT_SIZE, COUNT_FORMAT, 0)
			write_packed(io, COUNT_SIZE, COUNT_FORMAT, 0)
		end

		# Computes the last frame for the sequence. The start frame is presumed to be 0.
		# I could cache it, but if someone pokes a frame value directly from the record it's on, I wouldn't know to recompute it at the moment.
		def last_frame
			(self.bones + self.skins + self.cameras + self.lights).map { |r| r.frame }.max
		end
	end

end; end

