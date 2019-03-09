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

fileprivate var runningProcesses = Set<Process>()

signal(SIGINT, SIG_IGN)

let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT)

sigintSource.setEventHandler(handler: {
	var didTerminateProcesses = false

	for process in runningProcesses {
		process.terminate()
		didTerminateProcesses = true
	}

	print()

	if !didTerminateProcesses {
		prompt()
		fflush(stdout)
	}
})

sigintSource.activate()

while true {
	prompt()

	if let line = readLine() {
		let statement = Statement(line)
		let commands = statement.commands
		var input: FileHandle
		var output: FileHandle

		if let inputRedirectPath = statement.inputRedirect {
			let fileURL = URL(fileURLWithPath: inputRedirectPath)
			let fileHandle = try FileHandle(forReadingFrom: fileURL)

			input = fileHandle
		}
		else {
			input = FileHandle.standardInput
		}

		for (index, command) in commands.enumerated() {
			let isLastCommand = index == commands.count-1
			let process = Process()

			process.standardInput = input

			if isLastCommand {
				if let outputRedirectPath = statement.outputRedirect {
					let fileURL = URL(fileURLWithPath: outputRedirectPath)

					if !FileManager.default.fileExists(atPath: fileURL.path) {
						FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
					}

					let fileHandle = try FileHandle(forWritingTo: fileURL)

					process.standardOutput = fileHandle
				}
				else {
					output = FileHandle.standardOutput
				}
			}
			else {
				let pipe = Pipe()

				output = pipe.fileHandleForWriting
				input = pipe.fileHandleForReading

				process.standardOutput = output
			}

			process.terminationHandler = { process in
				runningProcesses.remove(process)

				if let input = process.standardInput as? FileHandle, input !== FileHandle.standardInput {
					input.closeFile()
				}
				if let output = process.standardOutput as? FileHandle, output !== FileHandle.standardOutput {
					output.closeFile()
				}
				if let error = process.standardError as? FileHandle, error !== FileHandle.standardError {
					error.closeFile()
				}
			}

			if command.name == "cd" {
				if command.args.count > 0 {
					FileManager.default.changeCurrentDirectoryPath(command.args[1])
				}
				else {
					let enviroment = ProcessInfo.processInfo.environment

					if let home = enviroment["HOME"] {
						FileManager.default.changeCurrentDirectoryPath(home)
					}
				}
			}
			else if command.name == "exit" {
				exit(0)
			}
			else if let executablePath = lookUp(executableName: command.name) {
				process.executableURL = URL(fileURLWithPath: executablePath)
				process.arguments = command.args

				try process.run()
				runningProcesses.insert(process)

				if isLastCommand {
					process.waitUntilExit()
				}
			}
		}
	}
}
