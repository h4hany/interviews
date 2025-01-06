# https://leetcode.com/problems/sum-of-two-integers/
# @param {Integer} a
# @param {Integer} b
# @return {Integer}
# this only work for positve number
def get_sum(a, b)
  c = 0
  while b != 0
    c = a & b
    a = a ^ b
    b = c << 1
  end
  a
end

def get_sum2(a, b)
  positives = []
  negatives = []
  1.step(a.abs) do |i|
    if a >= 0
      positives << i
    else
      negatives << i
    end
  end
  1.step(b.abs) do |i|
    if b >= 0
      positives << i
    else
      negatives << i
    end
  end

  1.step(negatives.size) do |i|
    if positives.size == 0 && negatives.size >= 0
      break
    end
    positives.pop
    negatives.pop
  end
  positives.size > 0 ? positives.size : negatives.size * -1
end

puts get_sum(1, 2)
