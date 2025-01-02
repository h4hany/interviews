#!/user/bin/ruby
#https://www.hackerrank.com/challenges/acm-icpc-team/problem
#  The first is the maximum number of topics known, and the second is the number of teams that know that number of topics.
def bit_on_bit (topic, next_topic)
  (topic.to_i(2) | next_topic.to_i(2)).to_s(2).split('').map(&:to_i).reduce(0, :+)
end

def debug_info(var_name, value)
  puts "#{var_name}: #{value}"
end

def acmTeam(topic)
  # Write your code here
  teams = 0
  known_topics = 0
  topics_length = topic.length
  hash_topic_with_teams = {}
  repeated_hash = {}
  start = Time.now
  # code to time

  topic.each_with_index do |selected_topic, index|
    topics_length.times do |topics_length_index|

      # debug_info('topics_length',topics_length)
      next_topic = topic[topics_length_index]
      string_key_reverse = "( #{topics_length_index + 1},#{index + 1} ) , ( #{index + 1},#{topics_length_index + 1} )"
      string_key = "( #{index + 1},#{topics_length_index + 1} ) , ( #{topics_length_index + 1},#{index + 1} )"
      if repeated_hash[string_key] || repeated_hash[string_key_reverse]
        next
      else
        if selected_topic != next_topic
          # topic = %w[10101 11100 11010 00101]
          repeated_hash[string_key] = 1
          repeated_hash[string_key_reverse] = 1

          # puts repeated_hash
          puts "-----------------------( #{index + 1},#{topics_length_index + 1} )-------------------------------------"
          debug_info('selected_topic', selected_topic)

          debug_info('next_topic', next_topic)

          selected_know_topic = bit_on_bit(selected_topic, next_topic)
          debug_info('selected_know_topic', selected_know_topic)
          if hash_topic_with_teams[selected_know_topic]
            hash_topic_with_teams[selected_know_topic] += 1
          else
            hash_topic_with_teams[selected_know_topic] = 1
          end
        end
      end
    end
  end

  hash_topic_with_teams.each_pair do |key, value|
    if known_topics < key
      known_topics = key
      teams = value
    end
  end
  finish = Time.now

  diff = finish - start
  debug_info('time_finish', diff)
  [known_topics, teams]
end

n = 3
topic = %w[10101 11110 00010]
n = 3
# topic = %w[10101 11100 11010 00101]
puts acmTeam(topic)
