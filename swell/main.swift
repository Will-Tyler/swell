//
//  main.swift
//  swell
//
//  Created by Will Tyler on 3/8/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


fileprivate func lookUp(executableName name: String) -> String? {
	let fileManager = FileManager.default
	let environment = ProcessInfo.processInfo.environment
	let path = environment["PATH"]!
	let paths = path.split(separator: ":").map(String.init)

	for path in paths {
		let hypotheticalPath = URL(fileURLWithPath: path).appendingPathComponent(name).path

		if fileManager.fileExists(atPath: hypotheticalPath) {
			return hypotheticalPath
		}
	}

	return nil
}

while true {
	Shell.prompt()

	if let line = readLine() {
		let args = line.split(separator: " ").map(String.init)
		let process = Process()
		let pipe = Pipe()

		if let executablePath = lookUp(executableName: args[0]) {
			process.arguments = Array(args[1...])
			process.executableURL = URL(fileURLWithPath: executablePath)
			process.standardOutput = pipe.fileHandleForWriting

			try process.run()
			process.waitUntilExit()

			let data = pipe.fileHandleForReading.availableData
			let string = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)

			print(string)
		}
	}

}
