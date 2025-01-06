# The is_bad_version API is already defined for you.
# @param {Integer} version
# @return {boolean} whether the version is bad
# def is_bad_version(version):

# @param {Integer} n
# @return {Integer}

def first_bad_version(n)
  array_bad_ver = []
  beg = 0
  last = n

  while beg <= last

    med = beg + (last - beg) /2
    if is_bad_version(med)
      array_bad_ver.push(med)
      last = med -1
    else
      beg = med +1
    end
  end

  array_bad_ver.last
end


