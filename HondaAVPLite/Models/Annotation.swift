import Foundation
import simd

/// Spatial annotation model for Supabase
/// Represents a point in 3D space with a text label
struct Annotation: Codable, Identifiable {
    /// Unique identifier
    let id: UUID

    /// X coordinate in meters (right = positive)
    let positionX: Float

    /// Y coordinate in meters (up = positive)
    let positionY: Float

    /// Z coordinate in meters (behind camera = positive, in front = negative)
    let positionZ: Float

    /// Text label to display
    let textLabel: String

    /// When the annotation was created
    let createdAt: Date

    /// 3D position as SIMD vector
    var position: SIMD3<Float> {
        SIMD3<Float>(positionX, positionY, positionZ)
    }

    /// Map Supabase snake_case columns to Swift camelCase properties
    enum CodingKeys: String, CodingKey {
        case id
        case positionX = "position_x"
        case positionY = "position_y"
        case positionZ = "position_z"
        case textLabel = "text_label"
        case createdAt = "created_at"
    }
}
