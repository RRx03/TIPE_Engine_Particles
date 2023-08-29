import Foundation
import MetalKit


// MARK: - ATTENTION VERTEX DESCRIPTOR
class Renderer: NSObject {
    static var device: MTLDevice!
    static var library: MTLLibrary!
    static var commandQueue: MTLCommandQueue!

    var pipelineStateRender: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState?

    var uniform = Uniforms()
    var params = Params()
    
    var gameScene : GameScene = GameScene()
    var particleMesh = ParticleMesh()
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    var particleBuffer : MTLBuffer!
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(
            descriptor: descriptor)
    }
    
    func initParticles(device: MTLDevice){
        particleBuffer = device.makeBuffer(length: MemoryLayout<Particle>.stride * commonVariables.particleCount, options: [])!
        var pointer = particleBuffer.contents().bindMemory(to: Particle.self, capacity: commonVariables.particleCount)
        for _ in GameScene.particles {
            pointer.pointee.modelMatrix = matrix_float4x4(translation: [Float(.random(in: 0...commonVariables.zoneRadius)), Float(.random(in: 0...commonVariables.zoneRadius)), Float(.random(in: 0...commonVariables.zoneRadius))])
            pointer = pointer.advanced(by: 1)
        }
    }

    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Could not set up the GPU or the Command Queue. Renderer init Error.")
        }

        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        depthStencilState = Self.buildDepthStencilState()

        super.init()

        let mainLibrary = device.makeDefaultLibrary()!
        Renderer.library = mainLibrary
        let vertexFunction = Self.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = Self.library?.makeFunction(name: "fragment_main")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(particleMesh.mesh.vertexDescriptor)
        
        do {
            pipelineStateRender = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            fatalError("Error, could not init pipelineStateRender. Renderer init error")
        }

        metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        initParticles(device: device)
        
        
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange _: CGSize) {
        params.width = Float(view.bounds.width)
        params.height = Float(view.bounds.height)
        commonVariables.width = view.bounds.width
        commonVariables.height = view.bounds.width
        var projectionMatrix: float4x4 {float4x4(projectionFov: commonVariables.fov, near: commonVariables.nearPlane, far: commonVariables.farPlane, aspect: Float(params.width)/Float(params.height))}
        uniform.projectionMatrix = projectionMatrix
        
    }

    func draw(in view: MTKView) {
        guard
            let commandBuffer: MTLCommandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        else {
            return
        }
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineStateRender)
        
        gameScene.sceneUpdate(deltaTime: deltaTime)
        
        uniform.viewMatrix = gameScene.camera.viewMatrix
        uniform.deltaTime = deltaTime;


        if (commonVariables.wireframe) {renderEncoder.setTriangleFillMode(.lines)}
        
        let submesh = particleMesh.mesh.submeshes[0]
        
        renderEncoder.setFragmentBytes(&params, length: MemoryLayout<Uniforms>.stride, index: 12)
        renderEncoder.setVertexBytes(&uniform, length: MemoryLayout<Uniforms>.stride, index: 11)
        renderEncoder.setVertexBuffer(particleMesh.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 1)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer:submesh.indexBuffer.buffer, indexBufferOffset: 0, instanceCount: commonVariables.particleCount)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        
        
        
    }
}
