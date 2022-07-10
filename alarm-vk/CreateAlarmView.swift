//
//  CreateAlarmView.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import Foundation
import SwiftUI

struct CreateAlarmView: View {
    @State var repeats = [
        ("Все", false),
        ("ПH", false),
        ("ВТ", false),
        ("СР", false),
        ("ЧТ", false),
        ("ПТ", false),
        ("СБ", false),
        ("ВС", false)
    ]
    var clouser: (Date, [(String, Bool)]) -> Void
    @State var date: Date = Date()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                List {
                    HStack {
                        ForEach(repeats.indices, id: \.self) { index in
                            ZStack {
                                if repeats[index].0 != "Все" {
                                Circle()
                                    .fill(repeats[index].1 ? .green : .gray)
                                }
                                Text(repeats[index].0)
                                    .foregroundColor(repeats[index].0 != "Все" ? .white : .accentColor)
                                    .onTapGesture {
                                        if repeats[index].0 == "Все" {
                                            for (a,_) in repeats.enumerated() {
                                                repeats[a].1 = true
                                            }
                                        }
                                        repeats[index].1.toggle()
                                    }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitle(Text("Новый будильник"), displayMode: .inline)
            .toolbar {
                Button {
                    clouser(date, repeats)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Сохранить")
                }
            }
        }
    }
}
