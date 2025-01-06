#!/user/bin/ruby
# - Given a short string S and a dictionary D, find out all possible ways to split S using words in D
#
# Test example:
#        S = 'abcd' D = ['a', 'b', 'ab', 'cd'] -> ['a b cd', 'ab cd']
# S = 'aaa' D = ['a'] -> ['a a a']
# S = 'abcd' D = ['ab'] -> []
# S = 'abcd' D = ['abcd'] -> ['abcd']

def word_break(s, dict)

end

s = 'abcd'
dict = %w[a b ab cd]
puts word_break(s, dict)
