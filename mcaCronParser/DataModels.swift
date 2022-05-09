//
//  DataModels.swift
//
//
//  Created by Marcela Auslenter on 07/05/2022.
//

import Foundation

struct Schedule: Codable {
    let hour: String
    let minutes: String
    let task: String
    
    init(from scheduleItems: [String]) {
        self.hour = scheduleItems[1]
        self.minutes = scheduleItems[0]
        self.task = scheduleItems[2]
    }
    
    var isEveryHour: Bool {
        hour == "*" ? true : false
    }
    
    var isEveryMinute: Bool {
        minutes == "*" ? true : false
    }
}

extension Schedule {
    static func timeStateForSpecificHourMinute(
        from schedule: Self,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleHour = Int(schedule.hour), let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled hour or minute has an invalid format")
            return .none
        }
        
        if scheduleHour == currentHour, scheduleMinutes == currentMinutes {
            return .equal
        } else if scheduleHour == currentHour {
            if scheduleMinutes < currentMinutes {
                return .before
            } else {
                return .after
            }
        } else if scheduleHour < currentHour {
            return .before
        } else if scheduleHour > currentHour {
            return .after
        }
        return .none
    }
    
    static func timeStateForSpecificHour(
        from schedule: Self,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleHour = Int(schedule.hour) else {
            print("The Scheduled hour has an invalid format")
            return .none
        }

        if scheduleHour == currentHour {
            return .equal
        } else if scheduleHour > currentHour {
            return .after
        } else if scheduleHour < currentHour {
            return .before
        }
        return .none
    }
    
    static func timeStateForSpecificMinutes(
        from schedule: Self,
        to currentHour: Int,
        and currentMinutes: Int
    ) -> TimeStates {
        guard let scheduleMinutes = Int(schedule.minutes) else {
            print("The Scheduled minutes has an invalid format")
            return .none
        }

        if scheduleMinutes == currentMinutes {
            return .equal
        } else if scheduleMinutes > currentMinutes {
            return .after
        } else if scheduleMinutes < currentMinutes {
            return .before
        }
        return .none
    }
}

struct CurrentTime: Codable {
    let hour: Int?
    let minutes: Int?
    
    init(from currentTime: String) {
        let timeElements = currentTime.components(separatedBy: ":")
        self.hour = Int(timeElements[0])
        self.minutes = Int(timeElements[1])
    }
}

enum TimeStates {
    case before
    case after
    case equal
    case none
}
