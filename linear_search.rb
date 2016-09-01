def linear_search(array, x)
  steps = 0
  for i in (0..array.length - 1)
    steps += 1

    if array[i] == x
      puts "Steps: #{steps}"
      return i
    end
  end

  puts "Steps: #{steps}"
  return -1
end
