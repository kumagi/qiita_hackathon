#!/usr/bin/env ruby

require 'qiita'
require 'json'

unless ARGV.count == 1
  puts "Usage: jubafeed.rb YOUR_QIITA_USER_NAME"
  puts "Set your token with export QIITA_TOKEN=[YOUR_TOKEN]"
  exit 1
end

QIITA = Qiita.new token: ENV['QIITA_TOKEN']

TARGET_FILE = "result.txt"
CONTINUATION = "continuation.txt"
user = ARGV[0]

$searched_users = []
$user_stack = []
$result = {}

def save_user_stocks(user)
  $searched_users << user
  response = QIITA.user_stocks(user, per_page: 100)
  uuids = response.map(&:uuid)
  $result[user] = uuids
  p ({ user: user, uuids: uuids })
  $user_stack += (response.map(&:stock_users).flatten - $searched_users - $user_stack)
end

def run
  until $user_stack.empty?
    save_user_stocks $user_stack.shift
  end
end

$user_stack << user

if File.exist?(CONTINUATION)
  json = JSON.parse(File.read(CONTINUATION))
  $searched_users = json["searched_users"]
  $user_stack     = json["user_stack"]
  $result         = json["result"]
end

begin
  run
ensure
  File.open(TARGET_FILE, 'w') do |f|
    f.write $result.to_json
  end
  File.open(CONTINUATION, 'w') do |f|
    f.write({ searched_users: $searched_users, user_stack: $user_stack, result: $result }.to_json)
  end
end
