import Foundation

enum AssetPrimaryCategory: String, CaseIterable, Identifiable, Codable {
    case liquid
    case fixed
    case investment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .liquid: return "????"
        case .fixed: return "????"
        case .investment: return "????"
        }
    }

    var defaultSubcategories: [AssetSubcategory] {
        switch self {
        case .liquid:
            return [
                AssetSubcategory(name: "???", isDefault: true),
                AssetSubcategory(name: "??", isDefault: true),
                AssetSubcategory(name: "????", isDefault: true)
            ]
        case .fixed:
            return [
                AssetSubcategory(name: "??", isDefault: true),
                AssetSubcategory(name: "??", isDefault: true)
            ]
        case .investment:
            return [
                AssetSubcategory(name: "????", isDefault: true),
                AssetSubcategory(name: "????", isDefault: true),
                AssetSubcategory(name: "??", isDefault: true),
                AssetSubcategory(name: "??", isDefault: true)
            ]
        }
    }
}

struct AssetSubcategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isDefault: Bool

    init(id: UUID = UUID(), name: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.isDefault = isDefault
    }
}
