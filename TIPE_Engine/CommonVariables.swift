import Foundation

enum commonVariables {
    static let fov : Float = 70
    static let nearPlane : Float = 0.1
    static let farPlane : Float = 100
    
    static var width : CGFloat = 1000
    static var height : CGFloat = 1000
    
    static var wireframe : Bool = false
    
    static var particleCount : Int = 100 //up to 100_000
    static var particleRadius : Float = 0.1
    static var meshPrecision : UInt32 = 10
    static var zoneRadius : Float = 3
}


enum Settings {
    static var rotationSpeed: Float { 2.0 }
    static var translationSpeed: Float { 3.0 }
    static var mouseScrollSensitivity: Float { 0.1 }
    static var mousePanSensitivity: Float { 0.008 }
}
