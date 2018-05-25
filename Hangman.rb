require 'oj'
require 'json'

class Hangman

  def initialize
    start_game
  end

  def pick_random_word
    dictionary = File.read("dictionary.txt").split("\r\n")
    valid_words = dictionary.select { |word| word.size >= 5 && word.size <= 12}
    word = valid_words.sample.downcase.split("")
  end

  def display_status
    puts "Guesses remaining: #{@guesses_remaining}"
    puts "Guessed letters: #{@guessed_letters.join(", ")}"
    puts @board_status.join()
  end

  def guess_letter
    puts "\nGuess a letter, or type 'save', to save and quit the current game."
    guessed_letter = gets.chomp.downcase
    puts
    if guessed_letter == "save"
      save_game
    elsif @word.include?(guessed_letter)
      @word.each_with_index do |letter, index|
        @board_status[index] = guessed_letter if letter == guessed_letter
      end
      puts "The word contains the letter '#{guessed_letter}'!"
    else
      @guesses_remaining -= 1
      puts "Sorry, the word does not contain that letter."
    end
    @guessed_letters << guessed_letter
    display_status
  end

  def game_over?
    if @guesses_remaining == 0
      puts "Oops, the word was '#{@word.join}', you lose!"
      return true
    elsif !@board_status.include?("_")
      puts "You Win!"
      return true
    else
      return false
    end
  end

  def start_game
    puts "New game of Hangman started!"
    @word = pick_random_word
    @guesses_remaining = 5
    @guessed_letters = []
    @board_status = Array.new(@word.size, "_")
    display_status
    guess_letter while !game_over?
  end

  def save_game
    puts "What would you like to save your game as?"
    filename = gets.chomp
    Dir.mkdir "saved_games" unless Dir.exists? "saved_games"
    filepath = "saved_games/#{filename}"
    File.open(filepath, 'w') do |file|
      file.puts Oj.dump self
    end
    puts "Game saved successfully! Quitting..."
    exit
  end
end

def load_game
  puts "\nSelect a game:"
  saved_games = Dir.entries("saved_games").reject{|entry| entry == "." || entry == ".."}
  puts saved_games
  filename = gets.chomp
  filepath = "saved_games/#{filename}"
  file = File.open(filepath, 'r')
  game = Oj.load(file)
  file.close
  game.display_status
  game.guess_letter while !game.game_over?
end

puts "Welcome to Hangman!\nType 'new' to start a new game, or 'load' to continue playing."
input = gets.chomp.downcase
if input == "load" && Dir.exists?("saved_games")
  load_game
else
  Hangman.new
end
