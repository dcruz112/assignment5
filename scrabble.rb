# lines = array of the input file
lines=[]

File.open("INPUT.json") do |file|
	lines = file.map { |line| line }
end

# board = integer of where board appears in array
board = lines.index{|e| e=~ /board/}

# dictionary = integer of where dictionary appears in array
dictionary = lines.index{|e| e=~ /dictionary/}

# tiles = integer of where tiles appears in array
tiles = lines.index{|e| e=~ /tiles/}

board_array = []
start_board = board

while start_board < (dictionary - 2) do
	board_line = lines[start_board + 1].gsub(/\D/, '').split(//)
	board_array << board_line
	start_board += 1
end

height = board_array.length
width = board_array[0].length

# array of the words: "word",

dictionary_array = []
start_words = dictionary

while start_words < (tiles - 2) do
	word = lines[start_words + 1].gsub(/\W/, '')
	if word.length <= width || word.length <= height
		dictionary_array << word
	end
	start_words += 1
end

# array of the tiles: "a1",

tile_array = []
start_tiles = tiles

while start_tiles < (lines.length - 3) do
	tile_array << lines[start_tiles + 1].gsub(/\W/, '')
	start_tiles += 1
end

# create tile_letters, same as tile_arrays

tile_letters = []
tHash = Hash.new([])

tile_array.each do |piece|
	tile_letters << piece[0]
	tHash[piece[0].to_sym] = piece[1]
end

moves = []

#For each word, this loop checks if it is possible, given the tiles

dictionary_array.each do |current_word|
	makeable = true
	word_letters = current_word.split(//) 
		#Turns the word into an array of its letters
	tiles_dup = tile_letters.dup 
		#Creates a duplicate array of available tiles

	#For each letter in the word, the loop checks if the current letter is an 
	#available tile in the duplicate list if it is possible, the letter is 
	#deleted from word_letters and from the list of available tiles

	word_letters.each do |current_letter|
		if tiles_dup.include? current_letter
			tiles_dup.delete_at(tiles_dup.index(current_letter))
		else
			makeable = false
			break
		end
	end

	#If there are any letters that did not match to a tile, then valid will be 
	#false. Otherwise, it is added to the array of possible words

	if makeable
		moves << current_word
	end
end

# turn given word into array of its letters' values

tile_vals = []

moves.each do |current_word|
	word_values = []
	the_letters = current_word.split(//)
	the_letters.each do |current_letter|
		num = tHash[current_letter.to_sym]
		word_values << num.to_i
	end
	tile_vals << word_values
end

max = 0
max_word = ""
max_row = 0
max_col = 0
horizontal = true

tile_vals.each do |piece|
	len = piece.length
	word = moves[tile_vals.index(piece)]
	board_array.each_with_index do |line, index_row|
		board_array[index_row].each_with_index do |column, index_col|
			if width - index_row >= len
				i = index_col
				total = 0
				while i < len do
					total += board_array[index_row][i].to_i * piece[i]
					i += 1
				end
				if max < total
					max = total
					max_word = word.dup
					max_row = index_row
					max_col = index_col
					horizontal = true
				end
			else
				break
			end
		end
	end
end

puts max_word