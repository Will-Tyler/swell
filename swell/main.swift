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
		let commands = line.split(separator: "|").map(String.init)
		var input = FileHandle.standardInput
		var output = FileHandle.standardOutput
		var lastProcess: Process?

		for (index, var command) in commands.enumerated() {
			let process = Process()

			process.standardInput = input
			command = command.trimmingCharacters(in: .whitespacesAndNewlines)

			if (index == commands.count-1) {
				output = FileHandle.standardOutput
				lastProcess = process
			}
			else {
				let pipe = Pipe()

				output = pipe.fileHandleForWriting
				input = pipe.fileHandleForReading
			}

			process.standardOutput = output

			if index < commands.count-1 {
				process.terminationHandler = { process in
					if let output = process.standardOutput as? FileHandle {
						output.closeFile()
					}
				}
			}

			let args = command.split(separator: " ").map(String.init)

			if let executablePath = lookUp(executableName: args[0]) {
				process.arguments = Array(args[1...])
				process.executableURL = URL(fileURLWithPath: executablePath)

				try process.run()
			}
		}

		lastProcess?.waitUntilExit()
	}

}
