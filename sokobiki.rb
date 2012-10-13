require 'qiita'
require 'json'

def get_following from
  q = JSON.parse(`curl https://qiita.com/api/v1/users/#{from}/following_users?token=05d1694574e340b39498dffa651474d6`)
  q.map{|user| user["url_name"]}
end

TARGET_FILE = "result.txt"
CONTINUATION = "continuation.txt"

$searched_users = []
$user_stack = []
$result = {}

def save_user_follows(user)
  $searched_users << user
  ap $searched_users
  followed = get_following user
  $result[user] = followed
  p ({ user => followed })
  $user_stack += (followed - $searched_users - $user_stack)
end

def run
  until $user_stack.empty?
    save_user_follows $user_stack.shift
  end
end


if File.exist?(CONTINUATION)
  json = JSON.parse(File.read(CONTINUATION))
  $searched_users = json["searched_users"]
  $user_stack     = json["user_stack"]
  $result         = json["result"]
end

$user_stack << "kumagi"
begin
  ap $user_stack
  run
rescue => e
  ap e
ensure
  File.open(TARGET_FILE, 'w') do |f|
    f.write $result.to_json
  end
  File.open(CONTINUATION, 'w') do |f|
    f.write({ searched_users: $searched_users, user_stack: $user_stack, result: $result }.to_json)
  end
end
