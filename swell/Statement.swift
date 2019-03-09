//
//  Statement.swift
//  swell
//
//  Created by Will Tyler on 3/9/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


struct Statement: ExpressibleByStringLiteral {
	
	typealias StringLiteralType = String

	let commands: [Command]
	let outputRedirect: String?
	let inputRedirect: String?

	init(stringLiteral string: String) {
		var tokens = string.split(separator: " ").map(String.init)

		if let lessThanIndex = tokens.firstIndex(of: "<") {
			self.inputRedirect = tokens[lessThanIndex+1]

			tokens.remove(at: lessThanIndex)
			tokens.remove(at: lessThanIndex)
		}
		else {
			inputRedirect = nil
		}
		
		if let greaterThanIndex = tokens.firstIndex(of: ">") {
			self.outputRedirect = tokens[greaterThanIndex+1]

			tokens.remove(at: greaterThanIndex)
			tokens.remove(at: greaterThanIndex)
		}
		else {
			outputRedirect = nil
		}

		self.commands = tokens.split(separator: "|").map(Array.init).map(Command.init)
	}

}
