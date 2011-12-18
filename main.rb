#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'book'
require 'kadailibrary'

ENV['AMAZONRCDIR'] = './'
ENV['AMAZONRCFILE'] = '.amazonrc'

puts Kadai::Library.search('4274066304').size








