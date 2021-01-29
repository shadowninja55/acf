module acf

import os

type AcfNode = string | map[string]AcfNode

pub fn (node AcfNode) as_str() string {
	return match node {
		string { node }
		else { "" }
	}
}

pub fn (node AcfNode) as_map() map[string]AcfNode {
	return match node {
		map[string]AcfNode { node }
		else { map[string]AcfNode{} }
	}
}

fn next_token(mut reader Reader) ?byte {
	for {
		token := reader.next()?

		match token {
			` `, `\n`, `\r`, `\t` { continue }
			else { return token }
		}
	}

	return none
}

fn parse_quote(mut reader Reader) ?string {
	mut res := ""

	for {
		token := reader.next()?

		if token == `"` {
			return res
		}
		
		res += rune(token).str()
	}

	return error("EOF")
}

fn parse(mut node map[string]AcfNode, mut reader Reader) ? {
	for {
		token := next_token(mut reader) or { return }

		match token {
			`}` { return }
			`"` {
				key := parse_quote(mut reader)?
				value_token := next_token(mut reader)?

				match value_token {
					`{` {
						mut value := map[string]AcfNode{}
						parse(mut value, mut reader)?
						node[key] = value
					}
					`"` { 
						value := parse_quote(mut reader)?
						node[key] = value
					}
					else { 
						return error("invalid token ${rune(value_token)} at index ${reader.pos - 1}") 
					}
				}
			}
			else { 
				return error("invalid token ${rune(token)} at index ${reader.pos - 1}")
			}
		}
	}
}

pub fn from_string(content string) ?map[string]AcfNode {
	mut node := map[string]AcfNode{}
	mut reader := Reader { content: content.bytes() }
	parse(mut node, mut reader)?

	return node
}

pub fn from_file(filename string) ?map[string]AcfNode {
	content := os.read_file(filename)?
	return from_string(content)
}