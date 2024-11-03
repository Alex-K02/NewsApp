//
//  Mainpage.swift
//  combiningSqlAndSwift
//
//  Created by Alex Kondratiev on 20.08.24.
//

import SwiftUI

struct Mainpage: View {
    var body: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        VStack(spacing: 16) {
            NewsBlockView(headline: "Breaking News: Market Crash", imageName: "news1")
            NewsBlockView(headline: "Weather Update: Storm Warning", imageName: "news2")
            NewsBlockView(headline: "Sports: Local Team Wins", imageName: "news3")
            NewsBlockView(headline: "Technology: New iPhone Released", imageName: "news4")
        }
        .padding()
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Mainpage()
}
