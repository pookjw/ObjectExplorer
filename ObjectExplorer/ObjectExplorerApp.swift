//
//  ObjectExplorerApp.swift
//  ObjectExplorer
//
//  Created by Jinwoo Kim on 5/5/23.
//

import SwiftUI

@main
struct ObjectExplorerApp: App {
    init() {
        setenv("MTL_HUD_ENABLED", "1", 1)
        dlopen("/usr/lib/libMTLHud.dylib", RTLD_NOW)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
