describe "TurtleGraphics" do
  describe "Turtle" do
    describe "#move" do
      it "Makes the turtle move up when the turtle faces up" do
        expected = [
          [0, 0, 0],
          [0, 1, 1],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          move
        end

        expect(result).to eq expected
      end

      it "Makes the turtle move right when the turtle faces right" do
        expected = [
          [0, 0, 0],
          [0, 1, 0],
          [0, 1, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          turn_right
          move
        end

        expect(result).to eq expected
      end

      it "Makes the turtle move left when it faces left" do
        expected = [
          [0, 1, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          turn_left
          move
        end

        expect(result).to eq expected
      end

      it "Checks turtle can be steered two consequitive times" do
        expected = [ [1, 1, 0],
          [0, 1, 1],
          [0, 0, 0]
        ]
        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(0, 0)
          move
          turn_right
          move
          turn_left
          move
        end

        expect(result).to eq expected
      end

      it "Spawns the turtle at the beginning of the row when it goes outside the right side of the canvas" do
        expected = [
          [2, 1, 1],
          [0, 0, 0],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(0, 0)
          3.times { move }
        end

        expect(result).to eq expected
      end

      it "Spawns the turtle at the beginning of the row when it goes outside the left side of the canvas" do
        expected = [
          [0, 0, 0],
          [1, 1, 1],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          2.times { turn_left }
          2.times { move }
        end

        expect(result).to eq expected
      end

      it "Spawns the turtle at the beginning of the column when it goes outside the bottom side of the canvas" do
        expected = [
          [0, 1, 0],
          [0, 1, 0],
          [0, 1, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          turn_right
          2.times { move }
        end

        expect(result).to eq expected
      end

      it "Spawns the turtle at the beginning of the column when it goes outside the top side of the canvas" do
        expected = [
          [0, 1, 0],
          [0, 1, 0],
          [0, 1, 0]
        ]
        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          turn_left
          2.times { move }
        end

        expect(result).to eq expected
      end

      it "Checks that the turtle can move around the canvas" do
        expected = [
          [2, 1, 1],
          [1, 1, 1],
          [1, 1, 1]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(0, 0)
          3.times { move }
          turn_right
          move
          turn_left
          2.times { move }
          3.times { turn_left }
          move
          turn_right
          2.times { move }
        end

        expect(result).to eq expected
      end
    end

    describe "#look" do
      it "Checks the turtle can 'look' left" do
        expected = [
          [0, 0, 0],
          [1, 1, 0],
          [0, 0, 0]
        ]
        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          look(:left)
          move
        end

        expect(result).to eq expected
      end

      it "Checks the turtle can 'look' right" do
        expected = [
          [0, 0, 0],
          [0, 1, 1],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          look(:right)
          move
        end

        expect(result).to eq expected
      end

      it "Checks the turtle can 'look' up" do
        expected = [
          [0, 1, 0],
          [0, 1, 0],
          [0, 0, 0]
        ]

        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          look(:up)
          move
        end

        expect(result).to eq expected
      end

      it "Checks the turtle can 'look' down" do
        expected = [
          [0, 0, 0],
          [0, 1, 0],
          [0, 1, 0]
        ]
        result = TurtleGraphics::Turtle.new(3, 3).draw do
          spawn_at(1, 1)
          look(:down)
          move
        end

        expect(result).to eq expected
      end
    end

  end
end
