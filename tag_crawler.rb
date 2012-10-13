require 'qiita'
require 'json'
require 'pp'

QIITA = Qiita.new token: "40e0577f4c5446d3a71564186def9963"
TARGET_FILE = "tag_result.txt"
CONTINUATION = "tag_continuation.txt"

$searched_users = []
$user_stack = []
$result = {}

def get_user_follow_tags(user)
  QIITA.user_following_tags user
end

def run
  users = JSON.parse(File.read("following.json")).map{ |user,follow|user}
  result = {}
  until users.empty?
    user = users.shift
    result = get_user_follow_tags user
    tags = result.map(&:name)
    puts "#{user} follows #{tags}"
    $result[user] = tags
  end
end

begin
  run
ensure
  File.open(TARGET_FILE, 'w') do |f|
    f.write $result.to_json
  end
end
