#!/user/bin/ruby
#https://www.hackerrank.com/challenges/acm-icpc-team/problem
#  The first is the maximum number of topics known, and the second is the number of teams that know that number of topics.
def bit_on_bit (topic, next_topic)
  (topic.to_i(2) | next_topic.to_i(2)).to_s(2).count('1')

end

def debug_info(var_name, value)
  puts "#{var_name}: #{value}"
end

def acmTeam(topic)
  # Write your code here
  topics_length = topic.length
  topics_hash = {}
  result_hash = { teams: 0, known_topics: 0 }
  topic.each_with_index do |selected_topic, index|
    topics_hash[index] = selected_topic
  end
  topic.each_with_index do |selected_topic, index|
    topics_length_index = index + 1
    rec_fun(topics_length_index, topics_length, topics_hash, selected_topic, result_hash, index)
  end
  [result_hash[:known_topics], result_hash[:teams]]
end

def rec_fun(topics_length_index, topics_length, topics_hash, selected_topic, result_hash, index)
  if topics_length_index < topics_length
    next_topic = topics_hash[topics_length_index]
    # puts "-----------------------( #{index + 1},#{topics_length_index + 1} )-------------------------------------"
    # debug_info('selected_topic', selected_topic)
    #
    # debug_info('next_topic', next_topic)
    selected_know_topic = bit_on_bit(selected_topic, next_topic)
    if selected_know_topic > result_hash[:known_topics]
      result_hash[:teams] = 1
      result_hash[:known_topics] = selected_know_topic
    elsif selected_know_topic == result_hash[:known_topics]
      result_hash[:teams] += 1
    end
    topics_length_index += 1
    rec_fun(topics_length_index, topics_length, topics_hash, selected_topic, result_hash, index)

  end
end

n = 3
topic = %w[10101 11110 00010]
n = 3
topic = %w[10101 11100 11010 00101]
puts acmTeam(topic)
