#!/usr/bin/env ruby
#
# Affiche la liste formattée des messages Slack contenant `:rocket:`
# Usage:
#   SLACK_API_TOKEN=<token> ./rockets-to-text.rb

require 'json'
require 'net/http'
require 'uri'

if ENV['SLACK_API_TOKEN'] == nil
  raise <<~TOKEN
    La variable d’environnement `SLACK_API_TOKEN` est vide.
    Générez un token d’API sur 'https://api.slack.com/custom-integrations/legacy-tokens', et relancez le script en précisant le token.
    (Exemple : `SLACK_API_TOKEN=<token> ./rockets-to-text.rb`)
  TOKEN
end

slack_search_url = 'https://slack.com/api/search.messages'
params = {
  token: ENV['SLACK_API_TOKEN'],
  query: ':rocket:',
  sort: 'date',
  sort_dir: 'desc',
  count: 1000
}

uri = URI.parse(slack_search_url)
uri.query = URI.encode_www_form(params)

response = Net::HTTP.get(uri)
payload = JSON.parse(response)

payload.dig('messages', 'matches').each do |message|
  date   = Time.at(message['ts'].to_i).strftime('%d/%m/%Y')
  author = message['username']
  text   = message['text']
             .gsub(/:rocket:([[:blank:]]*)/, '')
             .gsub(/<http([^\s]*)>/, 'http\1')
  puts <<~TEMPLATE
    #{date} - @#{author}
    #{text}

  TEMPLATE
end
