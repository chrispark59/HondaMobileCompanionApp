import Foundation
import Supabase

/// Service for fetching annotation data from Supabase
@MainActor
final class SupabaseService {
    /// Shared instance
    static let shared = SupabaseService()

    /// Supabase client
    private let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    /// Fetch all annotations from Supabase
    /// - Returns: Array of annotations, empty if none found
    /// - Throws: Error if network request fails
    func fetchAnnotations() async throws -> [Annotation] {
        do {
            let annotations: [Annotation] = try await client
                .from("annotations")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            return annotations
        } catch {
            throw SupabaseServiceError.fetchFailed(error.localizedDescription)
        }
    }
}

/// Errors that can occur when using SupabaseService
enum SupabaseServiceError: LocalizedError {
    case fetchFailed(String)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Unable to retrieve data: \(message)"
        }
    }
}
