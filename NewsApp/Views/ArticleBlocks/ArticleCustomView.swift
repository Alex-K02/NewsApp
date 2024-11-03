//
//  ArticleCustomView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 13.09.24.
//

import SwiftUI

struct ArticleCustomView: View {
    
    var body: some View {
        ScrollView {
            //NavigationBarItemsView()
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Text("\(convertDateToString(date: Date()))")//article.pubDate!
                            .underline(true)
                        Text("Author")//article.author!
                            .textCase(.uppercase)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black)
                            .cornerRadius(3.0)
                        Text("theverge.com")//article.domain!
                    }
                    .font(.subheadline)
                    .padding(.bottom)
                }
                
                Text("Scammers are increasingly using messaging and social media apps to attack")//article.title!
                    .fontWeight(.bold)
                    .font(.title)
                Text("Meta platforms, alongside Telegram, are among the growing number of sites used as a form of contact in 45% of scams.")//article.descrip!
                    .padding(.vertical)
                Text("Maintext")//article.maintext!
                    .font(.body)
                    .padding(.top)
                Spacer()
            }
            .padding()
            
        }
    }
    
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}

#Preview {
    ArticleCustomView()
}
