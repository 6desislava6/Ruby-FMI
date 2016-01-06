class Card
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace].reverse
  SUITS =[:spades, :hearts, :diamonds,:clubs]

  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def inspect
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def ==(other)
    @rank == other.rank and @suit == other.suit
  end

  def <=>(other)
   comparison_suit = SUITS.index(@suit) <=> SUITS.index(other.suit)
   comparison_rank = RANKS.index(@rank) <=> RANKS.index(other.rank)
   return comparison_suit unless comparison_suit == 0
   return comparison_rank
  end

  def self.generate_full_deck
    RANKS.product(SUITS).map{|x| Card.new(x.first, x.last)}
  end
end

module Sizeable
  def size
    @cards.size
  end
end

class Deck
  include Sizeable
  include Enumerable
  DEFAULT_DECK =Card.generate_full_deck
  DEFAULT_HAND = DEFAULT_DECK.size

  def initialize(cards: DEFAULT_DECK)
    @cards = cards
  end

  def draw_top_card
    self.next
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort!
  end

  def each
    @cards.each{|card| yield(card)}
  end

  def to_s
    @cards.reduce("") {|whole_string, x| whole_string + "\n" + x.to_s}
  end

  def deal
    hand = Class.new
  end
end

class NewDeck < Deck
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
end

#p cards = Card.generate_full_deck
#p cards = cards.sort
#p cards = cards.shuffle
#p cards = cards.sort
deck = Deck.new
deck.sort
puts deck
puts deck.size
newdeck = NewDeck.new
newdeck.sort
puts newdeck
