//
//  QLipaApp.swift
//  QLipa
//
//  Created by user on 2021/05/09.
//

import SwiftUI

@main
struct QLipaApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: QLipaDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
