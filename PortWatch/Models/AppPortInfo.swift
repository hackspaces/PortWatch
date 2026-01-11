import Foundation
import SwiftUI

struct AppPortInfo: Identifiable, Hashable {
    let id = UUID()
    let appName: String
    let ports: [Int]
    let pids: Set<Int>

    var displayName: String {
        // Decode escape sequences like \x20 (space), \x2d (hyphen), etc.
        var result = appName
        let pattern = "\\\\x([0-9A-Fa-f]{2})"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, range: range).reversed()
            for match in matches {
                if let hexRange = Range(match.range(at: 1), in: result),
                   let fullRange = Range(match.range, in: result),
                   let value = UInt8(result[hexRange], radix: 16) {
                    let char = String(UnicodeScalar(value))
                    result.replaceSubrange(fullRange, with: char)
                }
            }
        }
        return result
    }

    var portsDisplay: String {
        ports.sorted().map { String($0) }.joined(separator: ", ")
    }

    var iconName: String {
        let name = displayName.lowercased()
        switch name {
        case let n where n.contains("node"):
            return "hexagon.fill"
        case let n where n.contains("python"):
            return "chevron.left.forwardslash.chevron.right"
        case let n where n.contains("java"):
            return "cup.and.saucer.fill"
        case let n where n.contains("docker"), let n where n.contains("com.docke"):
            return "shippingbox.fill"
        case let n where n.contains("postgres"):
            return "cylinder.split.1x2.fill"
        case let n where n.contains("mysql"):
            return "cylinder.fill"
        case let n where n.contains("redis"):
            return "bolt.fill"
        case let n where n.contains("mongo"):
            return "leaf.fill"
        case let n where n.contains("nginx"), let n where n.contains("apache"):
            return "server.rack"
        case let n where n.contains("code"):
            return "curlybraces"
        case let n where n.contains("control"):
            return "slider.horizontal.3"
        case let n where n.contains("rapportd"):
            return "antenna.radiowaves.left.and.right"
        case let n where n.contains("onedrive"):
            return "cloud.fill"
        default:
            return "app.fill"
        }
    }

    var iconColor: Color {
        let name = displayName.lowercased()
        switch name {
        case let n where n.contains("node"):
            return .green
        case let n where n.contains("python"):
            return .yellow
        case let n where n.contains("java"):
            return .orange
        case let n where n.contains("docker"), let n where n.contains("com.docke"):
            return .blue
        case let n where n.contains("postgres"):
            return .blue
        case let n where n.contains("mysql"):
            return .orange
        case let n where n.contains("redis"):
            return .red
        case let n where n.contains("mongo"):
            return .green
        case let n where n.contains("nginx"):
            return .green
        case let n where n.contains("code"):
            return .blue
        case let n where n.contains("control"):
            return .gray
        case let n where n.contains("rapportd"):
            return .purple
        case let n where n.contains("onedrive"):
            return .blue
        default:
            return .secondary
        }
    }
}
