import Foundation
import SwiftUI
import MetalKit



struct MetalViewRepresentable: NSViewRepresentable {
  @Binding var metalView: MTKView

  func makeNSView(context: Context) -> some NSView {
    metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
    
  func updateMetalView() {
  }
}



struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    
    var body: some View {
      MetalViewRepresentable(metalView: $metalView)
        .onAppear {
          renderer = Renderer(metalView: metalView)
        }
    }
        
    
}
