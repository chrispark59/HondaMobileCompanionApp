import SwiftUI
import RealityKit
import ARKit

/// SwiftUI wrapper for ARView
struct ARViewerView: UIViewRepresentable {
    /// Reference to the ARView for external access (e.g., adding entities)
    @Binding var arView: ARView?

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [] // No plane detection needed for this MVP

        // Start AR session
        arView.session.run(config)

        // Store reference
        DispatchQueue.main.async {
            self.arView = arView
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // No updates needed
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        // Pause AR session when view is removed
        uiView.session.pause()
    }
}
