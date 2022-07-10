//
//  AlarmView.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import Foundation
import SwiftUI

struct AlarmView : View {
    var alarmData: Alarm
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(alarmData.time!, formatter: formatter)")
                    .font(.title3)
                HStack {
                    if let repeats = alarmData.repeats {
                        Text("Будильник\(createRepeats(repeats))")
                            .font(.subheadline)
                    }
                }
            }
            .foregroundColor(alarmData.active ? .green : .red)
        }
    }
    func createRepeats(_ repeats: [String]) -> String {
        var stroke = ""
        for sting in repeats {
            stroke.append(", " + sting)
        }
        return "\(stroke)"
    }
}

