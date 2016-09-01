def bubble_sort(array)
  loop do
    swapped = false
    for current in (0..array.length - 2)
      if array[current] > array[current + 1]
        swapped = true
        swapped_value = array[current]
        array[current] = array[current + 1]
        array[current + 1] = swapped_value
      end
    end

    break if !swapped
  end

  array
end
