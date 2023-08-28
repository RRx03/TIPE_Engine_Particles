import Foundation
import MetalKit




class GameScene{
    var camera : Camera = Camera()
    static var particles : [Particle] = [Particle](repeatElement(Particle(), count: commonVariables.particleCount))
    
 
    func sceneUpdate(deltaTime: Float){
        camera.update(deltaTime: deltaTime)
    }
    init(){
        camera.position = [0, 1.5, -11]
    }
    
    
}
