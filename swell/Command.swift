//
//  Command.swift
//  swell
//
//  Created by Will Tyler on 3/9/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


struct Command {

	let name: String
	let args: [String]

	init(_ tokens: [String]) {
		self.name = tokens[0]

		var args = Array(tokens[1...])

		if let home = ProcessInfo.processInfo.environment["HOME"] {
			for (index, arg) in args.enumerated() {
				args[index] = arg.replacingOccurrences(of: "~", with: home)
			}
		}

		self.args = args
	}

}
