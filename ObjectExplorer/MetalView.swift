//
//  MetalView.swift
//  ObjectExplorer
//
//  Created by Jinwoo Kim on 5/5/23.
//

import SwiftUI
import ObjectExplorerRenderer

#if os(macOS)
struct MetalView: NSViewRepresentable {
    func makeNSView(context: Context) -> MTKView {
        context.coordinator.mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        let mtkView: DynamicMTKView = .init()
        let coordinator: Coordinator = .init(mtkView: mtkView)
        return coordinator
    }
}
#elseif os(iOS)
struct MetalView: UIViewRepresentable {
    func makeUIView(context: Context) -> MTKView {
        context.coordinator.mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        let mtkView: DynamicMTKView = .init()
        let coordinator: Coordinator = .init(mtkView: mtkView)
        return coordinator
    }
}
#endif

extension MetalView {
    actor Coordinator: NSObject {
        fileprivate let mtkView: DynamicMTKView
        private let renderer: ExplorerRenderer
        private let setupTask: Task<Void, Never>
        
        init(mtkView: DynamicMTKView) {
            let renderer: ExplorerRenderer = .init()
            
            let setupTask: Task<Void, Never> = .init {                
                try! await renderer.setup(mtkView: mtkView, modelType: .room)
            }
            
            self.mtkView = mtkView
            self.renderer = renderer
            self.setupTask = setupTask
            
            super.init()
            
            Task { @MainActor in
#if os(macOS)
                let magnificationGesture: NSMagnificationGestureRecognizer = .init(target: self, action: #selector(triggeredMagnificationGesture(_:)))
                mtkView.addGestureRecognizer(magnificationGesture)
                
                let panGesture: NSPanGestureRecognizer = .init(target: self, action: #selector(triggeredPanGesture(_:)))
                mtkView.addGestureRecognizer(panGesture)
#elseif os(iOS)
                
#endif
            }
        }
        
        deinit {
            setupTask.cancel()
        }
        
#if os(macOS)
        @objc private nonisolated func triggeredMagnificationGesture(_ sender: NSMagnificationGestureRecognizer) {
            Task { @MainActor in
                switch sender.state {
                case .changed:
                    renderer.didChangeMagnification(scale: sender.magnification)
                case .possible:
                    renderer.didEndMagnification(scale: sender.magnification)
                default:
                    break
                }
            }
        }
        
        @objc private nonisolated func triggeredPanGesture(_ sender: NSPanGestureRecognizer) {
            Task { @MainActor in
                switch sender.state {
                case .changed:
                    let velocity: NSPoint = sender.velocity(in: sender.view)
                    renderer.didChangePanning(x: velocity.x, y: velocity.y)
                default:
                    break
                }
            }
        }
#elseif os(iOS)
#endif
    }
}
