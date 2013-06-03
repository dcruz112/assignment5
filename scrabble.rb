class Scrabble

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

	puts "this is the dictionary:"
	# array of the words: "word",
	dictionary_array = []
	start_words = dictionary
	while start_words < (tiles - 2) do
		dictionary_array << lines[start_words + 1].gsub(/\W/, '')
		start_words += 1
	end
	puts dictionary_array
	puts ""

	puts "these are the tiles:"
	# array of the tiles: "a1",
	tile_array = []
	tile_letters = []
	start_tiles = tiles
	while start_tiles < (lines.length - 3) do
		# tile = lines[start_tiles + 1].gsub('a', 'A')
		tile_array << lines[start_tiles + 1].gsub(/\W/, '')
		start_tiles += 1
	end

	# create tile_letters, same as tile_arrays
	a = 0
	while a < tile_array.length do
		tile_letters << tile_array[a]
		a += 1
	end

	# tile_letters.gsub('a', 'A')

	puts "TILE array"
	puts tile_array

end