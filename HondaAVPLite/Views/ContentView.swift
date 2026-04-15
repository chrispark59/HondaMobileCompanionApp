import SwiftUI
import RealityKit

/// Main content view with AR viewer and controls
struct ContentView: View {
    @StateObject private var viewModel = ARViewModel()
    @State private var arView: ARView?

    var body: some View {
        ZStack {
            // AR View (full screen)
            ARViewerView(arView: $arView)
                .ignoresSafeArea()

            // Overlay UI
            VStack {
                Spacer()

                // Error message (if any)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                }

                // Refresh button
                Button(action: {
                    Task {
                        await viewModel.loadAnnotations(in: arView)
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text(viewModel.isLoading ? "Loading..." : "Refresh")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                .disabled(viewModel.isLoading)
                .padding(.bottom, 40)
            }
        }
        .task {
            // Auto-fetch on appear
            await viewModel.loadAnnotations(in: arView)
        }
    }
}
