//
//  TIPE_EngineApp.swift
//  TIPE_Engine
//
//  Created by Roman Roux on 27/08/2023.
//

import SwiftUI

@main
struct TIPE_EngineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().frame(width: commonVariables.width, height: commonVariables.height, alignment: .center).fixedSize()
        }.windowResizability(.contentSize)
    }
}
