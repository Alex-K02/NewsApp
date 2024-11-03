//
//  CustomDatePickerView.swift
//  NewsApp
//
//  Created by Alex Kondratiev on 27.10.24.
//

import SwiftUI
import UIKit

struct CustomDatePickerView: View {
    @Binding var selectedDate: Date
    @State private var isShowingMonthPicker = false
    @State var isShowingYearPicker: Bool = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        if isShowingYearPicker {
            formatter.dateFormat = "yyyy"
        }
        else {
            formatter.dateFormat = "MMMM yyyy"
        }
        return formatter
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                if isShowingYearPicker {
                    Text("Year")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                // Display Selected Date
                Text(dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .onTapGesture {
                        isShowingMonthPicker.toggle()
                    }
                    .popover(isPresented: $isShowingMonthPicker, arrowEdge: .top) {
                        MonthYearPicker(selectedDate: $selectedDate, isShowingYearPicker: $isShowingYearPicker)
                            .frame(width: 320, height: 300)
                            .presentationCompactAdaptation(.popover)
                    }
            }
            
            Spacer()
            
            HStack(spacing: 12)  {
                // Previous Month Button
                Button(action: {
                    if isShowingYearPicker {
                        changeYear(by: -1)
                    }
                    else {
                        changeMonth(by: -1)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.secondary)
                }
                
                // Next Month Button
                Button(action: {
                    if isShowingYearPicker {
                        changeYear(by: 1)
                    }
                    else {
                        changeMonth(by: 1)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // Function to Change Month
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func changeYear(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .year, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    @Binding var isShowingYearPicker: Bool
    
    var body: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedDate: Date = .init()
    CustomDatePickerView(selectedDate: $selectedDate)
}
