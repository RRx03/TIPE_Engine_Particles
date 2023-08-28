import Foundation
import CoreGraphics


struct Camera : Transformable{
    var transform: Transform = Transform()
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: commonVariables.fov,
            near: commonVariables.nearPlane,
            far: commonVariables.farPlane,
            aspect: Float(commonVariables.width)/Float(commonVariables.height))
    }
    
    var viewMatrix: float4x4 {
        (float4x4(translation: position) *
            float4x4(rotation: rotation)).inverse
    }

    
    mutating func update(size: CGSize) {
        var projectionMatrix: float4x4 {
            float4x4(
                projectionFov: commonVariables.fov,
                near: commonVariables.nearPlane,
                far: commonVariables.farPlane,
                aspect: Float(size.width)/Float(size.height))
        }
    }
    
    mutating func update(deltaTime: Float) {
        let transform = updateInput(deltaTime: deltaTime)
        rotation += transform.rotation
        position += transform.position
        }
}

extension Camera : MovableAware{}
