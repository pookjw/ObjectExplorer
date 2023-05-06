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
    actor Coordinator {
        fileprivate let mtkView: DynamicMTKView
        private let renderer: ExplorerRenderer
        private let setupTask: Task<Void, Never>
        
        
        init(mtkView: DynamicMTKView) {
            let renderer: ExplorerRenderer = .init()
            
            let setupTask: Task<Void, Never> = .init {
                try! await renderer.setup(mtkView: mtkView, modelType: .chocolateDonut)
            }
            
            self.mtkView = mtkView
            self.renderer = renderer
            self.setupTask = setupTask
        }
        
        deinit {
            setupTask.cancel()
        }
    }
}
