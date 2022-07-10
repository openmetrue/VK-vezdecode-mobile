//
//  alarm_vk_widget.swift
//  alarm-vk-widget
//
//  Created by Mark Khmelnitskii on 10.07.2022.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    @AppStorage("AlarmWidget", store: UserDefaults(suiteName: "group.com.clickey.alarm-vk")) var widgetData: Data?
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), alarmModel: nil, configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let date = Date()
        if let widgetData = widgetData,
           let alarms = try? JSONDecoder().decode([AlarmModel].self, from: widgetData) {
            let entry = SimpleEntry(date: date, alarmModel: bestDataForWidget(currentDate: date, alarms: alarms).first, configuration: configuration)
            completion(entry)
        } else {
            let entry = SimpleEntry(date: date, alarmModel: nil, configuration: configuration)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let date = Date()
        if let widgetData = widgetData,
           let alarms = try? JSONDecoder().decode([AlarmModel].self, from: widgetData) {
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: date)!
                let entry = SimpleEntry(date: entryDate, alarmModel: bestDataForWidget(currentDate: date, alarms: alarms).first, configuration: configuration)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .after(alarms.first!.date))
            completion(timeline)
        } else {
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: date)!
                let entry = SimpleEntry(date: entryDate, alarmModel: nil, configuration: configuration)
                entries.append(entry)
            }
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    func bestDataForWidget(currentDate: Date, alarms: [AlarmModel]) -> [AlarmModel] {
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "h:mm"
        //MARK: нужно смотреть на дни недели!!!
        //var bestInterval: TimeInterval = alarms.first!.date.distance(to: currentDate)
        //var bestAlarm: AlarmModel = alarms.first!
        //for alarm in alarms {
//            if alarm.active == true,
//               alarm.date > currentDate {
//                let timeInterval = alarm.date.distance(to: currentDate)
//                if bestInterval <= timeInterval {
//                    bestInterval = timeInterval
//                    bestAlarm = alarm
//                }
//            }
        //}
        let alarms = alarms.filter { $0.active }.sorted { $0.date.distance(to: currentDate) < $1.date.distance(to: currentDate) && $1.date.distance(to: currentDate) > 0 }
        return alarms
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let alarmModel: AlarmModel?
    let configuration: ConfigurationIntent
}

struct alarm_vk_widgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        if let alarm = entry.alarmModel {
            VStack {
                Text("Следующий будильник: ")
                    .font(.body)
                    .bold()
                Text(alarm.date, style: .time)
                    .font(.title2)
                    .padding()
                Text("Открыть")
                    .foregroundColor(.accentColor)
            }
            .widgetURL(URL(string: "widget://timerID/\(alarm.id)"))
        } else {
            Text("Отсутствуют установленныe будильники")
                .font(.title3)
                .widgetURL(URL(string: "widget://timerID/"))
                .padding()
        }
    }
}

@main
struct alarm_vk_widget: Widget {
    let kind: String = "alarm_vk_widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            alarm_vk_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct alarm_vk_widget_Previews: PreviewProvider {
    static var previews: some View {
        alarm_vk_widgetEntryView(entry: SimpleEntry(date: Date(), alarmModel: nil, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
