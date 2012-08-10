#!/usr/bin/env ruby-1.9.3-p0

$LOAD_PATH << File.dirname(__FILE__)

require 'mmd/vmd/motion_data'
require 'hexdump'

def test(filename)
	motion_data = File.open(filename, 'r') do |io|
		motion_data = MMD::VMD::MotionData.new
		motion_data.read(io)
		motion_data
	end

	puts "File format: #{motion_data.magic}"
	puts "Motion data is for model: #{motion_data.model_name.encode($stdout.external_encoding || 'UTF-8')}"
	puts "Motion data ends at frame: #{motion_data.last_frame}"
end

if $0 == __FILE__
	ARGV.each do |filename|
		puts ""
		puts "Testing #{filename}..."
		test(filename)
	end
end
