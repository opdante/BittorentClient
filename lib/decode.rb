
 # Decode the string and return the object that it represents.
  # In the case that the string contains more than one adjacent
  # objects, an array of all adjacent objects is returned. If
  # the string is not a valid bencoded string, nil is returned.
  def bdecode
    @index = 0
    data = []
    while @index < self.length
      data << case self[@index]
      when /\d/
         decode_str
      when 'l'
        decode_list
      when 'i'
        decode_int
      when 'd'
        decode_dict
      else
        raise ArgumentError, "Cannot bdecode invalid string."
      end
      @index += 1
    end
    @index = 0
    data.length > 1 ? data : data[0]
  end

private
  # Decode a bencoded string.
  def decode_str
    index_of_last_digit = @index + self[@index..self.length - 1].index(':')
    length_of_string = self[(@index)..(@index + index_of_last_digit - 1)].to_i

    # The string itself starts 1 past the index of the last digit (because of the colon)
    # and ends 2 more than the length of the string past the index.
    string = self[(index_of_last_digit + 1)..(index_of_last_digit + length_of_string)]

    # Increment index by the length of the string plus the length of the digits.
    @index += index_of_last_digit - @index + length_of_string
    string
  end

  # Decode a bencoded integer.
  def decode_int
    # @index is at the position of the the 'i' so we just need everything between it
    # and the next appearance of 'e'.
    index_of_last_digit = self[@index..self.length - 1].index 'e'
    number_string = self[(@index + 1)..(@index + index_of_last_digit - 1)]
    @index += index_of_last_digit
    number_string.to_i
  end

  # Decode a bencoded list.
  def decode_list
    accumulator = []

    # Elements begin at one past the index of the 'l'.
    @index += 1
    while self[@index] != 'e'
      case self[@index]
      when /\d/
        accumulator << decode_str
      when 'l'
        accumulator << decode_list
      when 'i'
        accumulator << decode_int
      when 'd'
        accumulator << decode_dict
      else
        raise ArgumentError, "Cannot bdecode string."
      end
      @index += 1
    end
    accumulator
  end

  # Decode a bencoded dictionary.
  def decode_dict last_visited = @index
    hash = {}

    # Note: keys may only ever be strings (from specification).
    key = ''
    while self[@index] != 'e'
      case self[@index]
      when /\d/
        s = decode_str
        if key.empty?
          key = s
        else
          raise ArgumentError, "Invalid bencoded string" if key.empty?
          hash[key] = s
          key = ''
        end
      when 'l'
        raise ArgumentError, "Invalid bencoded string" if key.empty?
        hash[key] = decode_list
        key = ''
      when 'i'
        raise ArgumentError, "Invalid bencoded string" if key.empty?
        hash[key] = decode_int
        key = ''
      when 'd'
        # This is to prevent infinite recursion, which would happen if
        # this method was called on a string that was just a dictionary.
        unless @index == last_visited
          raise ArgumentError, "Invalid bencoded string" if key.empty?
          hash[key] = decode_dict @index
          key = ''
        end
      end
      @index += 1
    end
    hash
  end
end
