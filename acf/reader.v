module acf

struct Reader {
	content []byte
	mut:
		pos int
}

fn (mut reader Reader) next() ?byte {
	token := reader.content[reader.pos] or { 
		return error("EOF") 
	}
	
	reader.pos++
	return token
}