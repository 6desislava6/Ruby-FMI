module Mapping
  module_function
  FIRST_NUMBER_CHARACTER_VALUE = 1
  SECOND_NUMBER_CHARACTER_VALUE = 2
  LAST_NUMBER_CHARACTER_VALUE = 5
  NUMBERS_CHARACTER_VALUE = 4

  LAST_CHARACTER_VALUE = 4
  FIRST_CHARACTER_VALUE = 1
  # chars per button
  CHARS = 3

  def mapper(char)
    case char
    when '0'..'9'
      numbers_cases(char)
    when 'a'..'z'
      character_cases(char)
    else
      FIRST_CHARACTER_VALUE
    end
  end

  def numbers_cases(char)
    if ['7', '9'].member? char
      LAST_NUMBER_CHARACTER_VALUE
    elsif char == '1'
      FIRST_NUMBER_CHARACTER_VALUE
    elsif char == '0'
      SECOND_NUMBER_CHARACTER_VALUE
    else
      NUMBERS_CHARACTER_VALUE
    end
  end

  def character_cases(char)
    ord_to_presses = -> (x) { x % CHARS == 0? CHARS : x % CHARS}
    if ['z', 's'].member? char
      LAST_CHARACTER_VALUE
    elsif ('s'...'z').member? char
      # moving the characters to the left
      ord_to_presses.call(char.ord - 1)
    else
      ord_to_presses.call(char.ord)
    end
  end

end

def button_presses(sentence)
  sentence.downcase.each_char.map(&Mapping.method(:mapper)).reduce(0, &:+)
end

p button_presses('WHERE DO U WANT 2 MEET L8R')
p button_presses('')
p button_presses('111#*     ')
p button_presses('000 ')

#p Mapping.methods - Module.methods
#a = Mapping.method(:mapper)
#p a
#p &Mapping.mapper
#p ['a'].map(&Mapping.method(:mapper))
