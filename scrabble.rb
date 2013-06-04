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

info = Hash.new([])

def make_arrays(target, ref, lines, info, symbol)
	xray = []
	while target < (ref - 2) do
		x = lines[target + 1].gsub(/\W/, '')
		x = x.split(//) if symbol == "board"
		xray << x
		info[symbol.to_sym] = xray
		target += 1
	end
end

make_arrays(board, dictionary, lines, info, "board")
make_arrays(dictionary, tiles, lines, info, "dictionary")
make_arrays(tiles, lines.length - 1, lines, info, "tiles")

height = info[:board].length
width = info[:board][0].length

tile_letters = []
tHash = Hash.new([])

info[:tiles].each do |piece|
	tile_letters << piece[0]
	tHash[piece[0].to_sym] = piece.gsub(/\D/, '').to_i
end

moves = []

#For each word, this loop checks if it is possible, given the tiles

info[:dictionary].each do |current_word|
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
# array of arrays
tile_vals = []

moves.each do |current_word|
	word_values = []
	the_letters = current_word.split(//)
	the_letters.each do |current_letter|
		num = tHash[current_letter.to_sym] #.to_i
		word_values << num
	end
	tile_vals << word_values
end

max = { :val => 0, :word => "", :row => 0, :col => 0, :horiz => true }

def check_score(bound, incr_coord, fixed_coord, board, piece, word, len, max, isHoriz)
	if bound - incr_coord >= len
		i = 0
		total = 0
		c = incr_coord
		while i < len do
			if isHoriz
				total += board[fixed_coord][c].to_i * piece[i]
			else
				total += board[c][fixed_coord].to_i * piece[i]
			end
			i += 1
			c += 1
		end
		if max[:val] < total
			max[:val] = total
			max[:word] = word.dup
			if isHoriz
				max[:row] = fixed_coord
				max[:col] = incr_coord
			else
				max[:row] = incr_coord
				max[:col] = fixed_coord
			end
			max[:horiz] = isHoriz
		end
	end
end

tile_vals.each do |piece|
	len = piece.length
	word = moves[tile_vals.index(piece)]
	info[:board].each_with_index do |line, index_row|
		info[:board][index_row].each_with_index do |column, index_col|
			check_score(width, index_col, index_row, info[:board], piece, word, len, max, true)
			check_score(height, index_row, index_col, info[:board], piece, word, len, max, false)
		end
	end
end

word_letters = max[:word].split(//)

word_letters.each do |letter|
	info[:board][max[:row]][max[:col]] = letter
	if max[:horiz]
		max[:col] += 1
	else
		max[:row] += 1 
	end
end

info[:board].each do |row|
	puts row.join ' '
end