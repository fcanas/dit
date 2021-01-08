import Foundation

extension String {
    var bold: String {
        "\u{001B}[1m\(self)\u{001B}[22m"
    }
    var underline: String {
        "\u{001B}[4m\(self)\u{001B}[24m"
    }
}
