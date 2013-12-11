#  bencode.rb
#  
#  Copyright 2013 Thabang Ngazimbi
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

class String
=begin
A byte string is encoded as <length>:<contents>. The length is a 
positive base 10 integers, (zero is allowed);
the contents are just the bytes that make up the string.
=end
  def be_encode
    "#{self.length}:#{self}"
  end
end

class List
=begin
   A list of values is encoded as l<contents>e . The contents consist 
   of the bencoded elements of the list, in order,
   concatenated.
=end
  def be_encode
    "l#{map{ |obj| obj.be_encode }.join}e"
  end
end

class Integer
=begin
An integer is encoded as i<integer encoded in base ten ASCII>e. 
Leading zeros are not allowed. Negative values are
encoded by prefixing the number with a minus sign.
=end
  def be_encode
    "i#{self}e"
  end
end

class Hash
=begin
A dictionary is encoded as d<contents>e. The elements of the dictionary 
are encoded each key immediately followed by its value. All keys must be 
byte strings and must appear in lexicographical order.
=end
  def be_encode
    string = 'd'
    self.each do |k, v|
      raise ArgumentError, "Hash key must be of type String" unless k.class == String
      string << k.bencode + v.bencode
    end
    string + 'e'
  end
end
