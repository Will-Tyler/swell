//
//  Lexer.swift
//  swell
//
//  Created by Will Tyler on 4/30/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation

final class Lexer {

	typealias Pattern = String
	typealias Generator = (String)->Token
	typealias Tokenizer = (Pattern, Generator)
	typealias Tokenizers = [Tokenizer]

	let tokenizers: Tokenizers

	init(tokenizers: Tokenizers) {
		self.tokenizers = tokenizers
	}

	func parse(_ string: String) throws -> [Token] {
		var content = string
		var tokens = [Token]()

		while content.count > 0 {
			var foundMatch = false

			for (pattern, generator) in tokenizers {
				if let match = try content.matchFromBeginning(using: pattern) {
					let token = generator(match)

					tokens.append(token)
					content.removeFirst(match.count)
					foundMatch = true

					break
				}
			}

			if !foundMatch {
				throw LexerError.matchNotFound(content)
			}
		}

		return tokens
	}

}
