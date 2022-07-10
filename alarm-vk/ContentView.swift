//
//  ContentView.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @AppStorage("AlarmWidget", store: UserDefaults(suiteName: "group.com.clickey.alarm-vk")) var widgetData: Data?
    
    @ObservedObject var localNotification = LocalNotification()
    @ObservedObject var viewModel = ViewModel()
    @State var showSheet = false
    
    @State var openAlarmId = UUID().uuidString
    var body: some View {
        if (localNotification.notificationData != nil) {
            QuizView(viewModel: viewModel) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        stop()
                    }
                }
            }
            .transition(.opacity)
        } else {
            NavigationView {
                List {
                    ForEach(viewModel.alarms) { alarmVM in
                        NavigationLink(isActive: Binding(get: {
                            openAlarmId == alarmVM.id ?? UUID().uuidString
                        }, set: { value in
                            openAlarmId = value == false ? UUID().uuidString : alarmVM.id!
                        })) {
                            EditAlarmView(alarmData: alarmVM) { date, repeats, isActiveAlarm  in
                                viewModel.editAlarm(alarm: alarmVM, time: date, repeats: repeats, isActive: isActiveAlarm)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    bestAlarmForWidget()
                                }
                            }
                        } label: {
                            AlarmView(alarmData: alarmVM)
                        }
                    }
                    .onDelete { index in
                        index.forEach { (i) in
                            viewModel.deleteAlarm(alarm: viewModel.alarms[i])
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            bestAlarmForWidget()
                        }
                    }
                }
                .toolbar {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .navigationBarTitle("Будильник")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showSheet) {
                    CreateAlarmView { date, repeats in
                        viewModel.addAlarm(time: date, repeats: repeats)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            bestAlarmForWidget()
                        }
                    }
                }
                .onAppear {
                    viewModel.getRandomPokemon()
                    NotificationManager.shared.requestNotificationPermission()
                }
                .onOpenURL { url in
                    openAlarmId = url.pathComponents.last ?? ""
                }
            }
        }
    }
    private func stop() {
        localNotification.notificationData = nil
    }
    private func bestAlarmForWidget() {
        var alarms: [AlarmModel] = []
        for alarm in viewModel.alarms {
            alarms.append(AlarmModel(id: alarm.id!, date: alarm.time!, active: alarm.active, days: alarm.repeats!))
        }
        guard let data = try? JSONEncoder().encode(alarms) else {
            widgetData = nil
            return
        }
        widgetData = data
        WidgetCenter.shared.reloadTimelines(ofKind: "alarm_vk_widget")
    }
}
