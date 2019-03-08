//
//  Shell.swift
//  swell
//
//  Created by Will Tyler on 3/8/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


class Shell {

	static func prompt() {
		if isatty(0) > 0 {
			print("swell", terminator: " ")
		}
	}

}
