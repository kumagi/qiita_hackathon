require 'json'

inverse = {  }

JSON.parse(File.read('result.txt')).each { |user, ids|
  ids.each { |id|
    inverse[id] ||= []
    inverse[id] << user
  }
}

require 'pp'
pp inverse


ids.map { |id| { id => inverse[id].size } }
