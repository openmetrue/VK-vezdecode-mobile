//
//  EditAlarmView.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import Foundation
import SwiftUI

struct EditAlarmView: View {
    var alarmData: Alarm
    @State var date: Date = Date()
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
    var clouser: (Date, [(String, Bool)], Bool) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State var isActiveAlarm: Bool = false
    init(alarmData: Alarm, clouser: @escaping (Date, [(String, Bool)], Bool) -> Void) {
        self.alarmData = alarmData
        self.clouser = clouser
    }
    var body: some View {
        VStack {
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .onAppear {
                    self.date = alarmData.time!
                }
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
                .onAppear {
                    self.isActiveAlarm = alarmData.active
                    self.repeats = daysToTuple(from: alarmData.repeats!)
                }
                HStack {
                    Text("Активен:")
                    Spacer()
                    Toggle(isOn: $isActiveAlarm) {
                        isActiveAlarm ? Text("On") : Text("Off")
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationBarTitle(Text("Редактирование"), displayMode: .inline)
        .toolbar {
            Button {
                clouser(date, repeats, isActiveAlarm)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Сохранить")
            }
        }
    }
    private func daysToTuple(from data: [String]) -> [(String, Bool)] {
        return [
            ("Все", false),
            ("ПH", data.contains("ПH")),
            ("ВТ", data.contains("ВТ")),
            ("СР", data.contains("СР")),
            ("ЧТ", data.contains("ЧТ")),
            ("ПТ", data.contains("ПТ")),
            ("СБ", data.contains("СБ")),
            ("ВС", data.contains("ВС"))
        ]
    }
}

