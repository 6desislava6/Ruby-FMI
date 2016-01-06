describe 'Fourth Task' do
  describe Card do
    it "Returns the card's rank" do
      expect(Card.new(2, :spades).rank).to eq 2
    end

    it "Returns the cards suit" do
      expect(Card.new(:queen, :diamonds).suit).to eq :diamonds
    end

    it "Converts card to String when card rank is a digit" do
      expect(Card.new(10, :hearts).to_s).to eq "10 of Hearts"
    end

    it "Converts card to String when card rank is a symbol" do
      expect(Card.new(:ace, :spades).to_s).to eq "Ace of Spades"
    end

    it "Checks that two cards of the same rank and suit are equal" do
      expect(Card.new(:queen, :spades) == Card.new(:queen, :spades)).to be true
    end

    it "Checks that two cards of the same rank but different suit are not equal" do
      expect(Card.new(10, :hearts) == Card.new(10, :spades)).to be false
    end

    it "Checks that two cards of the same suit but different ranks are not equal" do
      expect(Card.new(:ace, :hearts) == Card.new(10, :hearts)).to be false
    end
  end

  describe Deck do
    DECK_SIZE = 5
    def standard_deck
      suits = [:clubs, :diamonds, :hearts, :spades]
      ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

      ranks.product(suits).collect {|rank, suit| Card.new(rank, suit)}
    end

    before :each do
      @deck = Deck.new(standard_deck.sample DECK_SIZE)
    end

    it "Checks that a standard deck with 52 cards is created implicitly if no arguments are passed to the constructor" do
      expect(Deck.new.size).to eq 52
      expect(Deck.new.to_a).to eq standard_deck
    end

    it "Checks that deck size decreases when the top card is drawn" do
      expect(@deck.size).to eq DECK_SIZE
      @deck.draw_top_card
      expect(@deck.size).to eq DECK_SIZE - 1
    end

    it "Checks that draw_top_card returns the correct card" do
      top_card = @deck.top_card
      expect(@deck.draw_top_card).to eq top_card
    end

    it "Checks that top_card does not change the deck size" do
      top_card = @deck.top_card
      expect(@deck.draw_top_card).to eq top_card
    end

    it "Checks that deck size decreases when the bottom card is drawn" do
      @deck.draw_bottom_card
      expect(@deck.size).to eq DECK_SIZE - 1
    end

    it "Checks that draw_bottom_card returns the correct card" do
      bottom_card = @deck.bottom_card
      expect(@deck.draw_bottom_card).to eq bottom_card
    end

    it "Checks that bottom_card does not change the deck size" do
      @deck.bottom_card
      expect(@deck.size).to eq DECK_SIZE
    end

    it "Checks that deck can be shuffled" do
      start_deck = standard_deck.sample(DECK_SIZE)
      deck = Deck.new(start_deck)

      deck.shuffle
      expect(deck.to_a).not_to be == start_deck
    end

    it "Checks that deck is sorted correctly" do
      sorted_deck = [Card.new(:ace, :spades), Card.new(:king, :hearts),
                     Card.new(:jack, :hearts), Card.new(10, :diamonds),
                     Card.new(2, :clubs)
                    ]
      deck = Deck.new(sorted_deck.shuffle)
      deck.sort
      expect(deck.to_a).to be == sorted_deck
    end
  end

  describe WarDeck do
    def standard_deck
      suits = [:clubs, :diamonds, :hearts, :spades]
      ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

      ranks.product(suits).collect {|rank, suit| Card.new(rank, suit)}
    end

    it "Checks that a war deck has all necessairy cards" do
      expect(WarDeck.new.to_a).to match_array standard_deck
    end

    it "Checks that a ward deck has 52 cards" do
      expect(WarDeck.new.size).to be 52
    end

    it "Checks that a player is delt 26 cards" do
      expect(WarDeck.new.deal.size).to be 26
    end

    it "Checks that a war deck is empty after two hands are delt" do
      deck = WarDeck.new
      2.times { deck.deal }
      expect(deck.size).to be 0
    end

    it "Checks that a WarDeck can be sorted" do
      sorted_deck = [Card.new(:ace, :spades), Card.new(:king, :hearts),
                     Card.new(:jack, :hearts), Card.new(10, :diamonds),
                     Card.new(2, :clubs)
                    ]
      deck = WarDeck.new(sorted_deck.shuffle)
      deck.sort
      expect(deck.to_a).to be == sorted_deck
    end
  end

  describe "Object returned by WarDeck#deal" do
    def standard_deck
      suits = [:clubs, :diamonds, :hearts, :spades]
      ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

      ranks.product(suits).collect {|rank, suit| Card.new(rank, suit)}
    end

    it "Checks that play card returns a card from the player's hand" do
      player_deck = WarDeck.new.deal
      player_hand_size = player_deck.size

      expect(standard_deck).to include(player_deck.play_card)
      expect(player_deck.size).to be player_hand_size - 1
    end

    it "Checks that player deck can face up when there are 3 or less cards in the player's hand" do
      cards = [Card.new(:ace, :spades), Card.new(7, :diamonds),
               Card.new(:king, :hearts)]
      expect(WarDeck.new(cards).deal.allow_face_up?).to be true
    end

    it "Chacks that player deck cannot face up when there are more than 3 cards in the player's card" do
      cards = [Card.new(:ace, :spades), Card.new(7, :diamonds),
               Card.new(:king, :hearts), Card.new(:king, :diamonds)
              ]
      expect(WarDeck.new(cards).deal.allow_face_up?).to be false
    end
  end

  describe BeloteDeck do
    def belote_deck
      ranks = [7, 8, 9, :jack, :queen, :king, 10, :ace]
      suits = [:clubs, :diamonds, :hearts, :spades]
      ranks.product(suits).map {|rank, suit| Card.new(rank, suit)}
    end

    it "Checks that a belote deck has the correct amout of cards" do
      expect(BeloteDeck.new.to_a.size).to be 32
    end

    it "Checks that a belote deck only has the cards needed to play belote" do
      expect(BeloteDeck.new.to_a).to match_array belote_deck
    end

    it "Checks that a belote deck can be sorted" do
      sorted_deck = [Card.new(:ace, :spades), Card.new(9, :spades),
                     Card.new(9, :hearts), Card.new(:ace, :diamonds),
                     Card.new(10, :diamonds), Card.new(:king, :diamonds),
                     Card.new(8, :clubs)
                    ]
      deck = BeloteDeck.new(sorted_deck.shuffle)
      deck.sort
      expect(deck.to_a).to be == sorted_deck
    end
  end

  describe "Object returned by BeloteDeck#deal" do
    it "Checks that highest_of_suit returns the correct card" do
      deck = [Card.new(:ace, :spades), Card.new(:king, :spades),
              Card.new(9, :spades), Card.new(9, :hearts),
              Card.new(:ace, :diamonds), Card.new(10, :diamonds),
              Card.new(:king, :diamonds), Card.new(8, :clubs)
             ]
      player_deck = BeloteDeck.new(deck).deal

      expect(player_deck.highest_of_suit(:spades)).to be == Card.new(:ace, :spades)
      expect(player_deck.highest_of_suit(:hearts)).to be == Card.new(9, :hearts)
      expect(player_deck.highest_of_suit(:clubs)).to be == Card.new(8, :clubs)
      expect(player_deck.highest_of_suit(:diamonds)).to be == Card.new(:ace, :diamonds)
    end

    it "Checks the hand for belote when it's present" do
      deck = [Card.new(:ace, :spades), Card.new(:king, :spades),
              Card.new(9, :spades), Card.new(9, :hearts),
              Card.new(:ace, :diamonds), Card.new(10, :diamonds),
              Card.new(:king, :diamonds), Card.new(:queen, :spades)
             ]

      player_deck = BeloteDeck.new(deck).deal

      expect(player_deck.belote?).to be true
    end

    it "Checks the hand for belote when it's not present" do
      deck = [Card.new(:ace, :spades), Card.new(:king, :spades),
              Card.new(9, :spades), Card.new(9, :hearts),
              Card.new(:ace, :diamonds), Card.new(10, :diamonds),
              Card.new(:king, :diamonds), Card.new(:jack, :spades)
             ]

      player_deck = BeloteDeck.new(deck).deal

      expect(player_deck.belote?).to be false
    end

    it "Checks the hand for tierce when it's present" do
      deck = [Card.new(:ace, :spades), Card.new(10, :spades),
              Card.new(:king, :spades), Card.new(8, :diamonds),
              Card.new(10, :hearts), Card.new(7, :clubs),
              Card.new(:jack, :spades), Card.new(:jack, :diamonds)
             ]
      player_deck = BeloteDeck.new(deck).deal
      expect(player_deck.tierce?).to be true
    end

    it "Checks the hand for tierce when it's present" do
      deck = [Card.new(7, :hearts), Card.new(7, :diamonds),
              Card.new(7, :spades), Card.new(7, :clubs),
              Card.new(8, :hearts), Card.new(8, :diamonds),
              Card.new(8, :spades), Card.new(:jack, :diamonds)
             ]
      player_deck = BeloteDeck.new(deck).deal
      expect(player_deck.tierce?).to be false
    end

    it "Checks the hand for carre_of_jacks when they are present" do
      deck = [Card.new(:jack, :hearts), Card.new(:jack, :diamonds),
              Card.new(:jack, :spades), Card.new(7, :clubs),
              Card.new(8, :hearts), Card.new(8, :diamonds),
              Card.new(8, :spades), Card.new(:jack, :clubs)
             ]
      player_deck = BeloteDeck.new(deck).deal
      expect(player_deck.carre_of_jacks?).to be true
    end

    it "Checks the hand for carre_of_jacks when they are not present" do
      deck = [Card.new(:jack, :hearts), Card.new(:jack, :diamonds),
              Card.new(:jack, :spades), Card.new(7, :clubs),
              Card.new(8, :hearts), Card.new(8, :diamonds),
              Card.new(8, :spades), Card.new(8, :clubs)
             ]
      player_deck = BeloteDeck.new(deck).deal
      expect(player_deck.carre_of_jacks?).to be false
    end
  end
end

