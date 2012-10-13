require 'jubatus/recommender/client'
require 'json'
require 'yaml'
require 'qiita'
require 'pp'

$cli = Jubatus::Client::Recommender.new "127.0.0.1", 9199
config = Jubatus::Config_data.new "inverted_index", YAML.load_file('num.yaml').to_json
$cli.set_config("a", config)

def convert_datum array
  param = array.map{|stock| [stock.to_s, 1.0]}
  Jubatus::Datum.new([],param)
end

TARGET_FILE = "result.txt"
QIITA = Qiita.new token: "05d1694574e340b39498dffa651474d6"
CONTINUATION = "continuation.txt"
INVERSE_MAP = "inverse_map.json"

def init
  $searched_users = []
  $user_stack = []
  $result = {}
  $inverse_map = {}
end


def jubafeed_user_stocks(user)
  $searched_users << user
  response = QIITA.user_stocks(user, per_page: 100)
  uuids = response.map(&:uuid)
  $result[user] = uuids
  $cli.update_row("a", user, convert_datum(uuids))
  p ({ user: user, uuids: uuids })
  $user_stack += (response.map(&:stock_users).flatten - $searched_users - $user_stack)

  uuids.each{ |uuid|
    $inverse_map[uuid] ||= 0
    $inverse_map[uuid] += 1
  }
  save_inverse_map
end

def save_inverse_map
  File.open(INVERSE_MAP, 'w') do |f|
    f.write($inverse_map.to_json)
  end
end

def run
  until $user_stack.empty?
    jubafeed_user_stocks $user_stack.shift
  end
end

init
$user_stack << "tomy_kaira"

if File.exist?(CONTINUATION)
  json = JSON.parse(File.read(CONTINUATION))
  $searched_users = json["searched_users"]
  $user_stack     = json["user_stack"]
  $result         = json["result"]
  $inverse_map    = json["inverse_map"]
end

begin
  loop do
    begin
      run
      seed = $searched_users.pop
      init
      $user_stack << seed
    rescue => e
      pp e
      sleep 5
    end
  end
rescue => e
  puts "error!"
  pp e
ensure
  puts "terminated"
  File.open(CONTINUATION, 'w') do |f|
    f.write({ searched_users: $searched_users, user_stack: $user_stack, result: $result , inverse_map: $inverse_map}.to_json)
  end
end
