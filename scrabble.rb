class Parser
	attr_accessor :board, :dictionary, :tiles

	def initialize
		@lines = []
		File.open("INPUT.json") do |file|
			@lines = file.map { |line| line }
		end
		@board = @lines.index{|e| e=~ /board/}
		@dictionary = @lines.index{|e| e=~ /dictionary/}
		@tiles = @lines.index{|e| e=~ /tiles/}
		@info = Hash.new([])
	end

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
		@tHash = Hash.new([])
		@pieces = parser.make_arrays(parser.tiles, parser.length - 1, "tiles")
		@tile_letters = []
		@tile_vals = []
		@word_values = []
		@letters = []
		@num = 0
	end

	def letters
		@pieces.each do |piece|
			@tile_letters << piece[0]
		end
		return @tile_letters
	end
	
	def values
		@pieces.each do |piece|
			@tile_vals << piece.gsub(/\D/, '').to_i
		end
		return @tile_vals
	end

	def table
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
		@word_letters = []
		@makeable = true
		@tile_list = tiles.letters
		@table = tiles.table
		@vals = []
	end

	def possible_moves

		#For each word, this loop checks if it is possible, given the tiles

		@dictionary.each do |current_word|
			@makeable = true
			@tiles_dup = @tile_list.dup
			@word_letters = current_word.split(//) 
				#Turns the word into an array of its letters

			#For each letter in the word, the loop checks if the current letter 
			#is an available tile in the duplicate list if it is possible, the 
			#letter is deleted from word_letters and the list of available tiles

			@word_letters.each do |current_letter|
				if @tiles_dup.include? current_letter
					@tiles_dup.delete_at(@tiles_dup.index(current_letter))
				else
					@makeable = false
					break
				end
			end

			#If there are any letters that did not match to a tile, then valid 
			#will be false. Otherwise, it's added to the array of possible words

			if @makeable
				@moves << current_word
			end
		end

		return @moves

	end

	def move_vals
		@moves.each do |word|
			@word_letters = word.split(//)
			@word_vals = []

			@word_letters.each do |letter|
				@word_vals << @table[letter.to_sym]
			end

			@vals << @word_vals
		end
		return @vals
	end

end

class Scorer

	attr_accessor :max

	def initialize
		@max = { :val => 0, :word => "", :row => 0, :col => 0, :horiz => true }
		@point_value = 0
		board = Board.new
		@field = board.mults
	end

	def check_score(bound, incr_coord, fixed_coord, piece, word, horiz)
		@total = 0
		@i = 0
		@len = piece.length
		if bound - incr_coord >= @len
			@c = incr_coord
			while @i < @len do
				@pt = horiz ? @field[fixed_coord][@c] : @field[@c][fixed_coord]
				@total += @pt.to_i * piece[@i]
				@i += 1
				@c += 1
			end
			check_max(@total, word, horiz, fixed_coord, incr_coord)
		end

		return @max
	end

	def check_max(comp_total, comp_word, bool, comp_fcoord, comp_icoord)
		if @max[:val] < comp_total
			@max[:val] = comp_total
			@max[:word] = comp_word
			if bool
				@max[:row] = comp_fcoord
				@max[:col] = comp_icoord
			else
				@max[:row] = comp_icoord
				@max[:col] = comp_fcoord
			end
			@max[:horiz] = bool
		end
	end

end

###############################################################################

board = Board.new
field = board.mults

tiles = TileSet.new
tile_letters = tiles.letters
table = tiles.table

dict = Dictionary.new
moves = dict.possible_moves
vals = dict.move_vals

scorer = Scorer.new
max = scorer.max

vals.each do |piece|
	word = moves[vals.index(piece)]
	field.each_with_index do |line, index_row|
		field[index_row].each_with_index do |column, index_col|
			max = scorer.check_score(board.width, index_col, index_row, piece, word, true)
			max = scorer.check_score(board.height, index_row, index_col, piece, word, false)
		end
	end
end

word_letters = max[:word].split(//)

word_letters.each do |letter|
	field[max[:row]][max[:col]] = letter
	max[:horiz] ? max[:col] += 1 : max[:row] += 1
end

field.each do |row|
	puts row.join ' '
end