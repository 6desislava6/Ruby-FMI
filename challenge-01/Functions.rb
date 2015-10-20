def complement(function)
  lambda {|*args| not function.call(*args)}
end

def compose(f_function, g_function)
  lambda do |*args|
    f_function.call(g_function.call(*args))
  end
end

