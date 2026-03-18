import Foundation

struct Project: Identifiable, Comparable {
    let id = UUID()
    let name: String
    var hasActiveSession: Bool

    static func < (lhs: Project, rhs: Project) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
