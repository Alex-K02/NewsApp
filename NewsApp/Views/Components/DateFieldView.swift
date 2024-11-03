//
//  DateFieldView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 22.09.24.
//

import SwiftUI

struct DateFieldView: View {
    var title: String
    
    @Binding var date: Date
    @FocusState var focused: Bool
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Date()
        return min...max
    }

    var body: some View {
        VStack(alignment: .leading) {
            DatePicker(
                selection: $date,
                in: dateRange,
                displayedComponents: .date
            ) {
                Text("Date of birth:")
            }
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.secondary))
        }
    }
}

#Preview {
    
    DateFieldView(title: "Date of birth:", date: .constant(Date()))
}
