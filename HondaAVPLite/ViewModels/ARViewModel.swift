import Foundation
import RealityKit
import Combine

/// ViewModel for managing AR annotations
@MainActor
final class ARViewModel: ObservableObject {
    /// Current annotations from Supabase
    @Published private(set) var annotations: [Annotation] = []

    /// Loading state
    @Published private(set) var isLoading = false

    /// Error message to display
    @Published var errorMessage: String?

    /// Anchor for all annotation entities
    private var annotationAnchor: AnchorEntity?

    /// Fetch annotations from Supabase and render them
    func loadAnnotations(in arView: ARView?) async {
        guard let arView = arView else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await SupabaseService.shared.fetchAnnotations()
            annotations = fetched
            renderAnnotations(in: arView)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Render all annotations as spheres in the AR scene
    private func renderAnnotations(in arView: ARView) {
        // Remove existing anchor if any
        if let existingAnchor = annotationAnchor {
            arView.scene.removeAnchor(existingAnchor)
        }

        // Create new anchor at world origin
        let anchor = AnchorEntity(world: .zero)
        annotationAnchor = anchor

        // Create sphere and text label for each annotation
        for annotation in annotations {
            let sphere = createSphereEntity(for: annotation)
            let textLabel = createTextEntity(for: annotation)
            anchor.addChild(sphere)
            anchor.addChild(textLabel)
        }

        // Add anchor to scene
        arView.scene.addAnchor(anchor)
    }

    /// Create a red sphere entity for an annotation
    private func createSphereEntity(for annotation: Annotation) -> ModelEntity {
        // Create sphere mesh (0.05m = 5cm radius)
        let mesh = MeshResource.generateSphere(radius: 0.05)

        // Create unlit red material (consistent appearance regardless of lighting)
        let material = UnlitMaterial(color: .red)

        // Create entity
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position at annotation coordinates
        entity.position = annotation.position

        return entity
    }

    /// Create a text label entity for an annotation
    private func createTextEntity(for annotation: Annotation) -> ModelEntity {
        // Create text mesh (0.05 font size = 5cm tall text)
        let mesh = MeshResource.generateText(
            annotation.textLabel,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.05),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        // White material for contrast against environment
        let material = UnlitMaterial(color: .white)

        // Create entity
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position above the sphere (0.08m = 8cm above sphere center)
        var position = annotation.position
        position.y += 0.08
        entity.position = position

        return entity
    }

    /// Clear all rendered annotations
    func clearAnnotations(in arView: ARView?) {
        guard let arView = arView, let anchor = annotationAnchor else { return }
        arView.scene.removeAnchor(anchor)
        annotationAnchor = nil
        annotations = []
    }
}
