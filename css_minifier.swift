// css_minifier.swift
import Foundation

class CSSMinifier {
    var removeComments: Bool
    var preserveSpaces: Bool
    var removeSemicolon: Bool
    var shrinkColors: Bool

    init(removeComments: Bool = true, preserveSpaces: Bool = false,
         removeSemicolon: Bool = true, shrinkColors: Bool = false) {
        self.removeComments = removeComments
        self.preserveSpaces = preserveSpaces
        self.removeSemicolon = removeSemicolon
        self.shrinkColors = shrinkColors
    }

    func minify(_ css: String) -> String {
        var result = css

        if removeComments {
            let regex = try! NSRegularExpression(pattern: "/\\*.*?\\*/", options: .dotMatchesLineSeparators)
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "")
        }

        let lines = result.components(separatedBy: .newlines)
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        result = trimmedLines.joined()

        if !preserveSpaces {
            let regex = try! NSRegularExpression(pattern: "\\s*([{}:;,>+~()])\\s*")
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "$1")
            let regex2 = try! NSRegularExpression(pattern: "\\s*,\\s*")
            result = regex2.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: ",")
        }

        if removeSemicolon {
            let regex = try! NSRegularExpression(pattern: ";}")
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "}")
        }

        if shrinkColors {
            let regex = try! NSRegularExpression(pattern: "#([0-9a-fA-F])\\1([0-9a-fA-F])\\2([0-9a-fA-F])\\3")
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "#$1$2$3")
            let regex2 = try! NSRegularExpression(pattern: "\\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)")
            result = regex2.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "0")
            let regex3 = try! NSRegularExpression(pattern: "\\b0+\\.(\\d+)")
            result = regex3.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: ".$1")
        }

        let regex = try! NSRegularExpression(pattern: "\n\\s*\n")
        result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: "\n")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

func main() {
    let args = CommandLine.arguments.dropFirst()
    var inputFile: String? = nil
    var outputFile: String? = nil
    var noComments = false
    var preserveSpaces = false
    var noSemicolon = false
    var shrinkColors = false

    var i = 0
    let argsArray = Array(args)
    while i < argsArray.count {
        switch argsArray[i] {
        case "--no-comments": noComments = true
        case "--preserve-spaces": preserveSpaces = true
        case "--no-semicolon": noSemicolon = true
        case "--shrink-colors": shrinkColors = true
        case "-o":
            if i+1 < argsArray.count { outputFile = argsArray[i+1]; i+=1 }
        default:
            if inputFile == nil { inputFile = argsArray[i] }
        }
        i+=1
    }

    let content: String
    if let input = inputFile {
        guard let data = try? String(contentsOfFile: input, encoding: .utf8) else {
            print("Error reading file", to: &stderr)
            exit(1)
        }
        content = data
    } else {
        var data = ""
        while let line = readLine() {
            data += line + "\n"
        }
        content = data
    }

    let minifier = CSSMinifier(
        removeComments: !noComments,
        preserveSpaces: preserveSpaces,
        removeSemicolon: !noSemicolon,
        shrinkColors: shrinkColors
    )
    let minified = minifier.minify(content)

    if let output = outputFile {
        try? minified.write(toFile: output, atomically: true, encoding: .utf8)
    } else {
        print(minified)
    }
}

main()
