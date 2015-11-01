triangular_numbers = Enumerator.new do |yielder|
  number = 0
  count = 1
  loop do
    number += count
    count += 1
    yielder.yield number
    # блокът след enumerator-а се изпълнява (т.е. този), когато
    # enum-ът трябва да даде нова стойност.
    # после си се връща, откъдето последно е yield-нал
    # стойността
  end
end

class Enumerator
  def infinite_select(&block)
    Enumerator.new do |yielder|
      # Еnumerator-ът (подава си)
      # от себе си подава value и го дава на другия
      # enumerator, който пък дава от своя страна
      # value-то при някакво условие на блока след себе си.
      self.each do |value|
        yielder.yield(value) if block.call(value)
      end
      # връща се нов enumerator, на който може да му се викне др метод.
    end
  end
end

# such chaining much wow
p triangular_numbers
.infinite_select {|val| val % 10 == 0}
.infinite_select {|val| val.to_s =~ /3/ }
.first(5)
# returns the first five triangular numbers that are multiples
# of 10 and that have the digit 3 in them
