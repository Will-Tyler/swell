//
//  main.swift
//  swell
//
//  Created by Will Tyler on 3/8/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


while true {
	Shell.prompt()

	if let line = readLine() {
		let process = Process()
		let pipe = Pipe()

		process.executableURL = URL(fileURLWithPath: "/bin/ls")
		process.standardOutput = pipe.fileHandleForWriting

		try process.run()
		process.waitUntilExit()

		let data = pipe.fileHandleForReading.availableData
		let string = String(data: data, encoding: .utf8)!

		print(string)
	}

}
