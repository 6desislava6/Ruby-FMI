def move(snake, direction)
  snake.drop(1) << new_head(snake, direction)
  # snake[1..-1] << new_head(snake, direction)
end

def grow(snake, direction)
  snake.dup << new_head(snake, direction)
end

def new_food(food, snake, dimensions)
  free_positions(dimensions[:width],
                      dimensions[:height],
                      food,
                      snake).shuffle().first
end

def obstacle_ahead?(snake, direction, dimensions)
  new_snake = move(snake, direction)
  newly_head = new_snake.last
  p newly_head

  outside_x      = outside_field?(newly_head[0], dimensions[:width])
  outside_y      = outside_field?(newly_head[1], dimensions[:height])
  self_collision = new_snake[0...-1].include? newly_head
  outside_x or outside_y or self_collision
end

def danger?(snake, direction, dimensions)
  return true if obstacle_ahead?(snake, direction, dimensions)
  obstacle_ahead?(move(snake, direction), direction, dimensions)
end

def new_head(snake, direction)
  [snake.last[0] + direction[0], snake.last[1] + direction[1]]
end

def outside_field?(coordinate, length)
  coordinate < 0 or coordinate >= length
end

def free_positions(dimension_x, dimension_y, food, snake)
  all_positions = (0...dimension_x).to_a.product((0...dimension_y).to_a)
  all_positions - food - snake
end

p move([[0, 0], [1, 0], [1, 1], [0, 1]], [0, -1])
p obstacle_ahead?([[0, 0], [0, 1], [0, 2], [1, 2], [1, 1]], [-1, 0], {width: 12, height: 12})

