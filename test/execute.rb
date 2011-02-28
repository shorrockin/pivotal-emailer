#!/usr/bin/env ruby
# I know this is a 'hack'. But it's easy. And easy is good. And it's 
# a simple way to toy around with email parsing.
require 'rubygems'
require 'bundler'
Bundler.require
require './utilities'

@log = Logger.new

def read(file)
  @log.debug(" === READING: #{file} === ")
  mail  = Mail.read(file)
  story = mail.to_story
  @log.debug(story.to_s)
  @log.debug("additional comments: #{mail.pivotal_comments.length}")
end

read("./test/mails/basic.eml")
read("./test/mails/basic_multipart.eml")
read("./test/mails/long.eml")
read("./test/mails/long_with_cc.eml")





