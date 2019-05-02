//
//  String.swift
//  swell
//
//  Created by Will Tyler on 5/2/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


fileprivate var expressions = [Lexer.Pattern: NSRegularExpression]()

extension String {

	func matchFromBeginning(using pattern: Lexer.Pattern) throws -> String? {
		let expression: NSRegularExpression

		if let exp = expressions[pattern] {
			expression = exp
		}
		else {
			expression = try NSRegularExpression(pattern: "^\(pattern)")
			expressions[pattern] = expression
		}

		let range = NSRange(location: 0, length: self.utf16.count)
		let result = expression.rangeOfFirstMatch(in: self, range: range)

		if result.location != NSNotFound {
			return (self as NSString).substring(with: result)
		}
		else {
			return nil
		}
	}

}
