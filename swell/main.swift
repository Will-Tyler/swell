//
//  main.swift
//  swell
//
//  Created by Will Tyler on 3/8/19.
//  Copyright © 2019 Will Tyler. All rights reserved.
//

import Foundation


fileprivate func prompt() {
	if isatty(0) > 0 {
		print("swell", terminator: " ")
	}
}

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
	prompt()

	if let line = readLine() {
		let commands = line.split(separator: "|").map(String.init)
		var input: FileHandle
		var output: FileHandle
		var lastProcess: Process?
		let tokens = line.split(separator: " ").map(String.init)

		if let lessThanIndex = tokens.firstIndex(where: { $0.first == "<" }) {
			let fileURL = URL(fileURLWithPath: tokens[lessThanIndex+1])
			let fileHandle = try FileHandle(forReadingFrom: fileURL)

			input = fileHandle
		}
		else {
			input = FileHandle.standardInput
		}

		for (index, var command) in commands.enumerated() {
			let process = Process()

			process.standardInput = input
			command = command.trimmingCharacters(in: .whitespacesAndNewlines)

			if (index == commands.count-1) {
				if let greaterThanIndex = tokens.firstIndex(where: { $0.first == ">" }) {
					let fileURL = URL(fileURLWithPath: tokens[greaterThanIndex+1])

					if !FileManager.default.fileExists(atPath: fileURL.path) {
						FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
					}

					let fileHandle = try FileHandle(forWritingTo: fileURL)

					process.standardOutput = fileHandle
					process.terminationHandler = { process in
						if let output = process.standardOutput as? FileHandle {
							output.closeFile()
						}
					}
				}
				else {
					output = FileHandle.standardOutput
				}

				lastProcess = process
			}
			else {
				let pipe = Pipe()

				output = pipe.fileHandleForWriting
				input = pipe.fileHandleForReading

				process.standardOutput = output
				process.terminationHandler = { process in
					if let output = process.standardOutput as? FileHandle {
						output.closeFile()
					}
				}
			}

			let args = command.split(separator: " ").map(String.init)

			if (args[0] == "cd") {
				if args.count > 1 {
					FileManager.default.changeCurrentDirectoryPath(args[1])
				}
				else {
					let enviroment = ProcessInfo.processInfo.environment

					if let home = enviroment["HOME"] {
						FileManager.default.changeCurrentDirectoryPath(home)
					}
				}
			}
			else if let executablePath = lookUp(executableName: args[0]) {
				process.arguments = Array(args[1...])
				process.executableURL = URL(fileURLWithPath: executablePath)

				try process.run()
			}
		}

		lastProcess?.waitUntilExit()
	}

}
