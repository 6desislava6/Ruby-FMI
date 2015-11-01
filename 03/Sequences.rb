class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each
    counter = 0
    row, col = 1, 1
    while counter < @limit
      if row.gcd(col) == 1
        yield Rational(row, col)
        counter += 1
      end
      row, col = calculate_direction(row, col)
    end
  end

  def calculate_direction(row, col)
    if col == 1 and row.odd?
      row += 1
    elsif row == 1 and col.even?
      col += 1
    elsif (row + col).even?
      row += 1
      col -= 1
    else
      row -= 1
      col += 1
    end
      return row, col
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each
    number, counter = 2, 0
    while counter < @limit
      if number.is_prime?
        yield(number)
        counter += 1
      end
      number += 1
    end
  end
end

class FibonacciSequence
   include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each
    first, second = @first, @second
    @limit.times do
      yield first
      first, second = second, first+second
    end
  end
end

class WorthlessRationalSequence < RationalSequence
  def each
    sum = 0
    row, col = 1, 1
    while sum < @limit
      number = Rational(row, col)
      break if sum + number > @limit
      if row.gcd(col) == 1
        yield number
        sum += number
      end
      row, col = calculate_direction(row, col)
    end
  end
end

module DrunkenMathematician
  module_function

  def meaningless(count)
    return 1 if count == 0
    groups = RationalSequence.new(count).to_a.group_by do |number|
      (number.numerator).is_prime? or (number.denominator).is_prime?
    end
    groups[true]  ||= []
    groups[false] ||= []
    groups[true].reduce(1, :*) / groups[false].reduce(1, :*)
  end

  def aimless(count)
    return 0 if count == 0
    numbers = PrimeSequence.new(count).each_slice(2).map do |pair|
      pair.length == 2? Rational(pair.first, pair.last) : Rational(pair.first)
    end
    numbers.reduce(:+)
  end

  def worthless(nth_fibonacci)
    return 0 if nth_fibonacci == 0
    limit = FibonacciSequence.new(nth_fibonacci).to_a.last
    WorthlessRationalSequence.new(limit).to_a
  end
end

class Integer
def is_prime?
    self == 1 ? false : (2..self / 2).none?{|i| self % i == 0}
  end
end

sequence = RationalSequence.new(0)
p sequence.to_a # => [(1/1), (2/1), (1/2), (1/3)]

sequence = PrimeSequence.new(0)
p sequence.to_a # => [2, 3, 5, 7, 11]

sequence = FibonacciSequence.new(0)
p sequence.to_a # => [1, 1, 2, 3, 5]

sequence = FibonacciSequence.new(0, first: 0, second: 1)
p sequence.to_a # => [0, 1, 1, 2, 3]

p DrunkenMathematician.meaningless(0) # => (1/4)
p DrunkenMathematician.worthless(0) # => [(1/1), (2/1), (1/2), (1/3)]
p DrunkenMathematician.aimless(0) # => (29/21)

