def binary_search(array, value, range = 0..array.length - 1, steps = 0)
  if range.begin > range.end
    puts "Steps: #{steps}"
    return -1 
  end

  steps += 1

  offset = range.begin
  middle_index = offset + (range.end - range.begin) / 2
  middle = array[middle_index]
  if middle == value
    puts "Steps: #{steps}"
    return middle_index 
  end

  if middle > value
    return binary_search(array, value, range.begin..middle_index - 1, steps)
  else
    return binary_search(array, value, middle_index + 1..range.end, steps)
  end
end
