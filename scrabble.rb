class Parser
	attr_accessor :board, :dictionary, :tiles

	def initialize
		# make array of lines of the input file
		@lines = []
		File.open("INPUT.json") do |file|
			@lines = file.map { |line| line }
		end

		# find where in the array these words appear
		@board = @lines.index{|e| e=~ /board/}
		@dictionary = @lines.index{|e| e=~ /dictionary/}
		@tiles = @lines.index{|e| e=~ /tiles/}
		@info = Hash.new([])
	end

	# return an array containing just the desired content
	def make_arrays(target, ref, symbol)
		xray = []
		while target < (ref - 2) do
			x = @lines[target + 1].gsub(/\W/, '')
			x = x.split(//) if symbol == "board"
			xray << x
			target += 1
		end
		return xray
	end

	def length
		return @lines.length
	end
end

class Board

	def initialize
		parser = Parser.new
		@board = parser.make_arrays(parser.board, parser.dictionary, "board")
	end

	def height
		return @board.length
	end

	def width
		return @board[0].length
	end

	def mults
		return @board
	end

end

class TileSet

	def initialize
		parser = Parser.new
		@pieces = parser.make_arrays(parser.tiles, parser.length - 1, "tiles")
	end

	#Creates an array with the letters of each tiles

	def letters
		@tile_letters = []
		@pieces.each do |piece|
			@tile_letters << piece[0]
		end
		return @tile_letters
	end

	#Creates an array with the values of each tiles
	
	def values
		@tile_vals = []
		@pieces.each do |piece|
			@tile_vals << piece.gsub(/\D/, '').to_i
		end
		return @tile_vals
	end

	#Creates a hash with the letters as a key and the numbers as values

	def table
		@tHash = Hash.new([])
		@tile_letters = letters
		@tile_vals = values
		@pieces.each_with_index do |piece, index|
			@tHash[@tile_letters[index].to_sym] = @tile_vals[index]
		end
		return @tHash
	end

end

class Dictionary
	attr_reader :makeable

	def initialize
		parser = Parser.new
		tiles = TileSet.new
		@dictionary = parser.make_arrays(parser.dictionary, parser.tiles, "dictionary")
		@moves = []
		@makeable = true
		@tile_list = tiles.letters
		@table = tiles.table
	end

	def possible_moves

		# For each word, this loop checks if it is possible, given the tiles
		@dictionary.each do |current_word|
			@makeable = true
			@tiles_dup = @tile_list.dup
			word_letters = current_word.split(//) 
				#Turns the word into an array of its letters

			# For each letter in the word, the loop checks if the current letter 
			# is an available tile in the duplicate list. If it is possible, the 
			# letter is deleted from word_letters and the list of available tiles
			word_letters.each do |current_letter|
				if @tiles_dup.include? current_letter
					@tiles_dup.delete_at(@tiles_dup.index(current_letter))
				else
					@makeable = false
					break
				end
			end

			# If there are any letters that did not match to a tile, then valid 
			# will be false. Otherwise, it's added to the array of possible words
			if @makeable
				@moves << current_word
			end
		end
		return @moves
	end

	# turn makeable words into array of their letters, puts each array into
	# vals, an array containing arrays of each words' letters
	def move_vals
		vals = []
		@moves.each do |word|
			word_letters = word.split(//)
			word_vals = []

			word_letters.each do |letter|
				word_vals << @table[letter.to_sym]
			end

			vals << word_vals
		end
		return vals
	end
end

class Scorer

	attr_accessor :max

	#Initializes the hash 'max' and gives the scorer access to the board

	def initialize
		@max = { :val => 0, :word => "", :row => 0, :col => 0, :horiz => true }
		board = Board.new
		@field = board.mults
	end

	#Calculates the score by multiplying the multipliers from each possible
	#move by the value of each letter

	def check_score(bound, incr_coord, fixed_coord, piece, word, horiz)
		@total = 0
		@i = 0
		@pt = 0
		@len = piece.length
		
		#If the word will fit in the space left on the board (between the edge
		#and the current position being tested)

		if bound - incr_coord >= @len
			
			#Rather than increment the variable incr_coord, we make a copy so 
			#when we go to store the starting position in max, incr_coord
			#has the correct value

			@c = incr_coord
			
			#i increments through the length of word

			while @i < @len do

				#Depending on whether the word reads horizontally or not, the
				#fixed_coord is in either the row or column position

				@pt = horiz ? @field[fixed_coord][@c] : @field[@c][fixed_coord]
				@total += @pt.to_i * piece[@i]
					#This multiplies the multiplier on the board by the value of
					#the letter. i and c are then incremented by 1
				@i += 1
				@c += 1
			end
			check_max(@total, word, horiz, fixed_coord, incr_coord)
				#This checks if the new total is greater than the max score.
		end

		return @max
	end

	#Compares the current score to the maximum score. If it is greater, all
	#information about the current configuration is stored in the hash 'max'

	def check_max(comp_total, comp_word, horiz, comp_fcoord, comp_icoord)
		if @max[:val] < comp_total

			@max[:val] = comp_total
			@max[:word] = comp_word

			#If the word is horizontal (reads left to right), then it increments
			#along the column.

			if horiz
				@max[:row] = comp_fcoord
				@max[:col] = comp_icoord

			#Otherwise, it reads from top to bottom, and increments by row

			else
				@max[:row] = comp_icoord
				@max[:col] = comp_fcoord
			end
			
			@max[:horiz] = horiz

		end
	end

end

board = Board.new
field = board.mults

dict = Dictionary.new
moves = dict.possible_moves
vals = dict.move_vals

scorer = Scorer.new
max = scorer.max

# Goes through vals, an array of arrays of each word's letters, one
# word at a time. Finds words that are possible by checking with dictionary.
# Then it checks the scores going through the rows and columns and finds
# the biggest word and its position.
vals.each do |piece|
	word = moves[vals.index(piece)]
	field.each_with_index do |line, index_row|
		field[index_row].each_with_index do |column, index_col|
			max = scorer.check_score(board.width, index_col, index_row, piece, word, true)
			max = scorer.check_score(board.height, index_row, index_col, piece, word, false)
		end
	end
end

# Turns biggest word into an array so it can be placed in the output board.
word_letters = max[:word].split(//)

word_letters.each do |letter|
	field[max[:row]][max[:col]] = letter
	max[:horiz] ? max[:col] += 1 : max[:row] += 1
end

field.each do |row|
	puts row.join ' '
end