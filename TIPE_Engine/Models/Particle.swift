import Foundation
import MetalKit

struct ParticleMesh {
    lazy var mesh: MTKMesh! = {
        var mtkMesh: MTKMesh
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        var sphereMesh = MDLMesh(sphereWithExtent: [commonVariables.particleRadius, commonVariables.particleRadius, commonVariables.particleRadius],
                                 segments: [commonVariables.meshPrecision, commonVariables.meshPrecision],
                                 inwardNormals: false,
                                 geometryType: .triangles,
                                 allocator: allocator)
        
        do {
            mtkMesh = try MTKMesh(mesh: sphereMesh, device: Renderer.device)
        } catch {
            fatalError("Error Mesh")
        }
        return mtkMesh
    }()
    
}
struct Particle {
    var modelMatrix : float4x4 = float4x4.identity
    var velocity : float3 = [0, 0, 0]
}


