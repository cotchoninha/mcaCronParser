//
//  CronParser.swift
//
//
//  Created by Marcela Auslenter on 09/05/2022.
//

import ArgumentParser
import Foundation

struct CronParser: ParsableCommand {
    
    static let configuration = CommandConfiguration(abstract: "CronParser", version: "0.0.1")
    
    @Argument(help: "Current hour") private var currentTime: String = ""
    @Argument(help: "Executable file") private var execFile: String = ""
    
    private var schedules = [Schedule]()
    
    mutating func run() throws {
        readFile()
    }
    
    private mutating func readFile() {
        var fileText = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(execFile)
            do {
                fileText = try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {
                print("Error reading file \(fileURL)", error.localizedDescription)
            }
        }
        createSchedules(with: fileText.components(separatedBy: "\n"))
    }
    
    private mutating func createSchedules(with scheduleFileComponents: [String]) {
        scheduleFileComponents.forEach { schedule in
            let scheduleItems = schedule.components(separatedBy: " ")
            guard !scheduleItems.isEmpty, let first = scheduleItems.first, !first.isEmpty else { return }
            schedules.append(Schedule(from: scheduleItems))
        }
        getExpectedTimeForChronometer()
    }
    
    private func getExpectedTimeForChronometer() {
        guard !currentTime.isEmpty, currentTime.contains(":") else {
            print("The input current time is invalid")
            return
        }
        
        let currentTime = CurrentTime(from: currentTime)
        guard let currentHour = currentTime.hour, let currentMinutes = currentTime.minutes else {
            print("The input current time is invalid")
            return
        }
        
        schedules.forEach { schedule in
            let everyHourMinute = (schedule.isEveryHour, schedule.isEveryMinute)
            
            switch everyHourMinute {
            case (true, true):
                print("\(currentHour):\(currentMinutes) today")
            case (false, true):
                outputForSpecificHourEveryMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            case (true, false):
                outputForEveryHourSpecificMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            case (false, false):
                outputForSpecificHourAndMinute(
                    currentHour: currentHour,
                    currentMinutes: currentMinutes,
                    schedule: schedule
                )
            }
        }
    }

    
    private func outputForSpecificHourAndMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return
        }
        
        let timeStates = Schedule.timeStateForSpecificHourMinute(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(scheduleHour):\(scheduleMinutes) tomorrow")
        case .after, .equal:
            print("\(scheduleHour):\(scheduleMinutes) today")
        case .none:
            print("There's an error parsing the time")
        }
    }
    
    private func outputForSpecificHourEveryMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        
        let timeStates = Schedule.timeStateForSpecificHour(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            print("\(schedule.hour):00 tomorrow")
        case .after:
            print("\(schedule.hour):00 today")
        case .equal:
            print("\(schedule.hour):\(currentMinutes) today")
        case .none:
            print("Error when parsing the time")

        }
    }
    
    private func outputForEveryHourSpecificMinute(
        currentHour: Int,
        currentMinutes: Int,
        schedule: Schedule
    ) {
        guard let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled minutes has an invalid format")
            return
        }
        
        let timeStates = Schedule.timeStateForSpecificMinutes(
            from: schedule,
            to: currentHour,
            and: currentMinutes
        )
        
        switch timeStates {
        case .before:
            let hourValue = currentHour == 23 ? "00" : String(currentHour + 1)
            let dayValue = hourValue == "00" ? "tomorrow" : "today"
            print("\(hourValue):\(scheduleMinutes) \(dayValue)")
        case .after:
            print("\(currentHour):\(scheduleMinutes) today")
        case .equal:
            print("\(currentHour):\(scheduleMinutes) today")
        case .none:
            print("There's an error parsing the time")
        }
    }
}
