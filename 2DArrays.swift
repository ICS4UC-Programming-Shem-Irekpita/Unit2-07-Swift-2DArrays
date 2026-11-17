//
//  2DArrays.swift
//
//  Created by Shem Irekpita on 2026-11-16.
//  Generates random student marks from text files and exports to CSV.
//

import Foundation

let meanMark = 75.0
let stdDevMark = 10.0

/// Generates a normally distributed random number using Box-Muller.
func nextGaussian(mean: Double, stdDev: Double) -> Double {
    let uniform1 = Double.random(in: Double.leastNonzeroMagnitude...1.0)
    let uniform2 = Double.random(in: 0.0...1.0)
    let zScore = sqrt(-2.0 * log(uniform1)) * cos(2.0 * .pi * uniform2)
    return zScore * stdDev + mean
}

/// Reads a text file line by line into a String array.
func readFileToArray(fileName: String) throws -> [String] {
    let content = try String(contentsOfFile: fileName, encoding: .utf8)
    return content
        .components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
}

/// Generates a 2D String array of random integer marks with a header row.
func generateMarks(
    studentArray: [String],
    assignmentsArray: [String]
) -> [[String]] {
    var marksTable: [[String]] = []

    var headerRow = ["Student"]
    headerRow.append(contentsOf: assignmentsArray)
    marksTable.append(headerRow)

    for student in studentArray {
        var row = [student]
        for _ in assignmentsArray {
            let rawMark = nextGaussian(mean: meanMark, stdDev: stdDevMark)
            let roundedMark = Int(rawMark.rounded())
            row.append(String(roundedMark))
        }
        marksTable.append(row)
    }

    return marksTable
}

/// Writes a 2D String array to a CSV file.
func writeToCsv(data: [[String]], outputFileName: String) throws {
    let csvText = data
        .map { $0.joined(separator: ",") }
        .joined(separator: "\n")
    try csvText.write(
        toFile: outputFileName,
        atomically: true,
        encoding: .utf8
    )
}

do {
    let studentArray = try readFileToArray(
        fileName: "Unit2-08-students.txt"
    )
    let assignmentsArray = try readFileToArray(
        fileName: "Unit2-08-assignments.txt"
    )

    let results = generateMarks(
        studentArray: studentArray,
        assignmentsArray: assignmentsArray
    )

    try writeToCsv(data: results, outputFileName: "marks.csv")
    print("Successfully generated marks.csv")
} catch {
    print("File error: \(error.localizedDescription)")
}