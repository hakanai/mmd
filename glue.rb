#!/usr/bin/env ruby-1.9.3-p0

$LOAD_PATH << File.dirname(__FILE__)

require 'mmd/vmd/motion_data'
require 'hexdump'

def glue_vmd_files(motion_file_1, motion_file_2, output_motion_file)
	motion_data_1 = MMD::VMD::MotionData.read_file(motion_file_1)
	motion_data_2 = MMD::VMD::MotionData.read_file(motion_file_2)

	# Put the start of motion data 2 immediately after the end of motion data 1.
	# This can be done better.
	# What we should be doing is taking the wav files as input as well so that we can offset to the start of the second wav once those are joined.
	motion_data_2.translate_frames(motion_data_1.last_frame + 1)

	motion_data_1.append(motion_data_2)

	motion_data_1.write_file(output_motion_file)

	puts "Wrote combined motion data to #{output_motion_file}"
end

if $0 == __FILE__
	motion_file_1 = ARGV[0]
	motion_file_2 = ARGV[1]
	output_motion_file = ARGV[2]

	if !output_motion_file
		puts "#{$0} - Glues together two motion data files."
		puts "usage: #{$0} file1 file2 outputfile"
		exit 1
	end

	glue_vmd_files(motion_file_1, motion_file_2, output_motion_file)
end
