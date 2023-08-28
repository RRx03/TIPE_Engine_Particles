import Foundation
import MetalKit
import GameController

// MARK: - Transform
struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var scale: Float = 1
}

extension Transform {
    var modelMatrix: matrix_float4x4 {
        let translation = float4x4(translation: position)
        let rotation = float4x4(rotation: rotation)
        let scale = float4x4(scaling: scale)
        let modelMatrix = translation * rotation * scale
        return modelMatrix
    }
}

protocol Transformable {
    var transform: Transform { get set }
    
}

extension Transformable {
    var position: float3 {
        get { transform.position }
        set { transform.position = newValue }
    }

    var rotation: float3 {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }

    var scale: Float {
        get { transform.scale }
        set { transform.scale = newValue }
    }
    
}

// MARK: - Vertex Descriptor Default Layouts
extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute( //vertices position, color
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        vertexDescriptor.attributes[1] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        vertexDescriptor.attributes[2] = MDLVertexAttribute(
            name: MDLVertexAttributeColor,
            format: .float3,
            offset: offset,
            bufferIndex: 0)
        offset += MemoryLayout<float3>.stride
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
        return vertexDescriptor
    }
}

// MARK: - Movement
protocol MovableAware where Self: Transformable {}

extension MovableAware {
    var forwardVector: float3 {
        normalize([sin(rotation.y), 0, cos(rotation.y)])
    }
    var rightVector: float3 {
      [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
    
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let rotationAmount = deltaTime * Settings.rotationSpeed
        let input = InputController.shared
        
        if input.keysPressed.contains(.leftArrow) {
            transform.rotation.y -= rotationAmount
        }
        if input.keysPressed.contains(.rightArrow) {
            transform.rotation.y += rotationAmount
        }
        var direction: float3 = .zero
        if input.keysPressed.contains(.keyW) {
          direction.z += 1
        }
        if input.keysPressed.contains(.keyS) {
          direction.z -= 1
        }
        if input.keysPressed.contains(.keyA) {
          direction.x -= 1
        }
        if input.keysPressed.contains(.keyD) {
          direction.x += 1
        }
        let translationAmount = deltaTime * Settings.translationSpeed
        if direction != .zero {
          direction = normalize(direction)
          transform.position += (direction.z * forwardVector
            + direction.x * rightVector) * translationAmount
        }
        return transform
    }

}

// MARK: - Input Parsing

class InputController {
    static let shared = InputController()
    var keysPressed: Set<GCKeyCode> = []

    private init() {
        let center = NotificationCenter.default
        center.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil, queue: nil)
        { notification in
            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler
                = { _, _, keyCode, pressed in
                    if pressed {
                        self.keysPressed.insert(keyCode)
                    } else {
                        self.keysPressed.remove(keyCode)
                    }
                }
        }
        #if os(macOS)
            NSEvent.addLocalMonitorForEvents(
                matching: [.keyUp, .keyDown]) { _ in nil }
        #endif
    }
}

// MARK: - Renderable

protocol Renderable{
    func render(renderEncoder: MTLRenderCommandEncoder, uniforms: Uniforms, params: Params)
}
