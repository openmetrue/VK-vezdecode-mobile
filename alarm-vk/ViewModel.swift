//
//  ViewModel.swift
//  alarm-vk
//
//  Created by Mark Khmelnitskii on 09.07.2022.
//

import SwiftUI
import Combine
import CoreData

class ViewModel: ObservableObject {
    @ObservedObject var localNotification: LocalNotification
    public let speechRecognizer = SpeechRecognizer()
    private var keywords: [String] = ["stop", "alarm for"]
    
    @Published var alarms: [Alarm] = []
    @Published var columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    @Published var pokemonName: String?
    @Published var pokemonImages: Sprites?
    @Published var pokemonColor: String = ""
    @Published var colors: [String] = []
    @Published var transcript = ""
    
    private var bag = Set<AnyCancellable>()
    
    init() {
        self.localNotification = LocalNotification()
        fetchAlarms()
        setUpSpeech()
    }
    
    private func setUpSpeech() {
        $transcript
            .debounce(for: .milliseconds(1000), scheduler: DispatchQueue.main)
            .map({ (string) -> String? in
                return string
            })
            .compactMap { $0?.lowercased() }
            .sink(receiveValue: {
                self.checkKeywords($0)
            }).store(in: &bag)
    }
    
    private func checkKeywords(_ text: String) {
        

        
        let keywordsFiltered = keywords.filter { text.contains($0) }
        if keywordsFiltered.last == "stop" {
            stop()
            speechRecognizer.stopRecording()
        } else if keywordsFiltered.last == "alarm for" && text.filter{Int("\($0)") != nil }.count >= 4 {
            let nums = text.filter{Int("\($0)") != nil }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hhmm"
            if let date = dateFormatter.date(from: "\(nums)") {
                addAlarm(time: date, repeats: [
                    ("Все", true),
                    ("ПH", true),
                    ("ВТ", true),
                    ("СР", true),
                    ("ЧТ", true),
                    ("ПТ", true),
                    ("СБ", true),
                    ("ВС", true)
                ])
            }
        }
    }
    
    public func stop() {
        localNotification.notificationData = nil
    }
    
    public func getRandomPokemon() {
        let randomID = Int.random(in: 1..<500)
        Publishers.Zip3(API.searchPokemonByID(randomID), API.getPokemonColorByID(randomID), API.getAllColors())
        .sink {
            switch $0 {
            case .finished:
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: {
            self.pokemonName = $0.0.name
            self.pokemonImages = $0.0.sprites
            self.pokemonColor = $0.1.color.name.uppercased()
            self.colors = ($0.2.results.map { result in result.name } + ["other", "skip"]).map { str in
                str.uppercased()
            }
        }
        .store(in: &bag)
    }
    
    public func fetchAlarms() {
        let request = NSFetchRequest<Alarm>(entityName: "Alarm")
        CoreDataService.shared.publicher(fetch: request)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: {
                self.alarms = $0
            }
            .store(in: &bag)
    }
    
    public func addAlarm(time: Date, repeats: [(String, Bool)]) {
        let id = UUID().uuidString
        let action: (() -> Void) = {
            let alarm: Alarm = CoreDataService.shared.createEntity()
            alarm.id = id
            alarm.time = time
            alarm.repeats = self.getDays(from: repeats)
            alarm.active = true
        }
        CoreDataService.shared.publicher(save: action)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: {
                switch $0 {
                case true:
                    DispatchQueue.main.async {
                        self.fetchAlarms()
                        NotificationManager.shared.scheduleRepeatedNotification(id: id, for: repeats, on: time)
                    }
                case false:
                    print("DB error")
                }
            }
            .store(in: &bag)
    }
    
    public func deleteAlarm(alarm: Alarm) {
        if alarm.active {
            NotificationManager.shared.cancelScheduledNotification(for: alarm.id!)
        }
        let action: (() -> Void) = {
            CoreDataService.shared.deleteEntity(entity: alarm)
        }
        CoreDataService.shared.publicher(save: action)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: {
                switch $0 {
                case true:
                    DispatchQueue.main.async {
                        self.fetchAlarms()
                    }
                case false:
                    print("DB error")
                }
            }.store(in: &bag)
    }
    
    func editAlarm(alarm: Alarm, time: Date, repeats: [(String, Bool)], isActive: Bool) {
        NotificationManager.shared.cancelScheduledNotification(for: alarm.id!)
        let action: (() -> Void) = {
            alarm.time = time
            alarm.repeats = self.getDays(from: repeats)
            alarm.active = isActive
        }
        CoreDataService.shared.publicher(save: action)
            .sink {
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: {
                switch $0 {
                case true:
                    DispatchQueue.main.async {
                        if isActive {
                            NotificationManager.shared.scheduleRepeatedNotification(id: alarm.id!, for: repeats, on: time)
                        } else {
                            NotificationManager.shared.cancelScheduledNotification(for: alarm.id!)
                        }
                        self.fetchAlarms()
                    }
                case false:
                    print("DB error")
                }
            }
            .store(in: &bag)
    }
    
    private func getDays(from data: [(String, Bool)]) -> [String] {
        var alarmRepeat = [String]()
        for days in data {
            if days.1 {
                alarmRepeat.append(days.0)
            }
        }
        return alarmRepeat
    }
    
    private func daysToTuple(from data: [String]) -> [(String, Bool)] {
        return [
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
