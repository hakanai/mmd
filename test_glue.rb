#!/usr/bin/env ruby-1.9.3-p0

$LOAD_PATH << File.dirname(__FILE__)

require 'mmd/pair'
require 'mmd/sequence'

def test
	sequence = MMD::Sequence.new

	# input
	sequence.append(:sound => 'oshiete.wav', :motion => 'oshiete.vmd')
	sequence.append(:sound => 'oshiete.wav', :motion => 'oshiete2.vmd')

	# output
	sequence.output(:sound => 'oshiete_glued.wav', :motion => 'oshiete_glued.vmd')

	sequence.close
end

if $0 == __FILE__
	test
end

