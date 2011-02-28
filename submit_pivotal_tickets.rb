#!/usr/bin/env ruby
# expects a 'config.yml' file to be sat alongside this script, currently
# only really tested with gmail. expects a format of: 
# pivotal:
#   api_token: ABCDEFG
#   project_id: 1234
# pop3:
#   server: pop.gmail.com
#   port: 995
#   username: username@gmail.com
#   password: 1234
#   ssl: true
#   delete_after_find: false

require 'rubygems'
require 'bundler'
Bundler.require
require './utilities'

log    = Logger.new
config = YAML::load_file('./config.yml')

log.error("invalid 'config.yml' file, please create this file, ensuring it has the correct format") and exit unless config
pop3_config = config['pop3']
piv_config  = config['pivotal']

log.error("invalid 'config.yml' file, please ensure this file has the correct format") and exit unless pop3_config and piv_config

Mail.defaults do
  retriever_method :pop3, { :address    => pop3_config['server'],
                            :port       => pop3_config['port'],
                            :user_name  => pop3_config['username'],
                            :password   => pop3_config['password'],
                            :enable_ssl => pop3_config['ssl'] }
end

log.debug("checking all email on #{pop3_config['server']}:#{pop3_config['port']} as #{pop3_config['username']}")
emails = Mail.all

if emails
  log.debug("found #{emails.length} new email(s) to process")
  PivotalTracker::Client.token   = piv_config['api_token']
  PivotalTracker::Client.use_ssl = true  

  PivotalTracker::Project.all # if not present then the project_id below will not be found
  project = PivotalTracker::Project.find(piv_config['project_id'])

  emails.each do |mail|
    log.debug("processing email with subject: #{mail.subject}")
    story = project.stories.create(mail.to_story)

    # pivotal api does not seem to support this at current. always ends up with a 500 error
    # mail.pivotal_comments.each do |comment|
      # log.debug("email was too long to fit into single description, adding remaining as comment for: #{mail.subject}")
      # story.notes.create(:text => comment)
    # end
  end

else
  log.info("no emails found, exiting")
end


