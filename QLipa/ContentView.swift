//
//  ContentView.swift
//  QLipa
//
//  Created by user on 2021/05/09.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: QLipaDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(QLipaDocument()))
    }
}
