# https://leetcode.com/problems/combination-sum/
# @param {Integer[]} candidates
# @param {Integer} target
# @return {Integer[][]}
def combination_sum(candidates, target)
  results = []
  find_combinations(results, [], candidates, target)
  results
end

def find_combinations(results, curr, candidates, target, idx=0)
  if target == 0
    results.push(curr.clone)
  else
    idx.upto(candidates.length-1) do |i|
      candidate = candidates[i]

      next if target - candidate < 0

      target -= candidate
      curr.push(candidate)

      find_combinations(results, curr, candidates, target, i)

      target += candidate
      curr.pop
    end
  end

end
