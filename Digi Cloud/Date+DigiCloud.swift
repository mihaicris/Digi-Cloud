//
//  Date+DigiCloud.swift
//  Digi Cloud
//
//  Created by Mihai Cristescu on 29/03/2017.
//  Copyright © 2017 Mihai Cristescu. All rights reserved.
//

import Foundation

extension Date {

    var timeAgoSyle: String {

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month

        let secondsAgo = Int(Date().timeIntervalSince(self))

        var output: String = ""

        switch secondsAgo {

        case 0..<2:
            output = NSLocalizedString("now", comment: "")

        case 2..<minute:
            output = "\(secondsAgo) seconds ago"

        case minute..<hour:

            let localizedString: String
            let minutesAgo = secondsAgo / minute

            if minutesAgo == 1 {
                localizedString = NSLocalizedString("%d minute ago", comment: "")
            } else {
                localizedString = NSLocalizedString("%d minutes ago", comment: "")
            }

            output = String(format: localizedString, minutesAgo)

        case hour..<day:

            let localizedString: String
            let hoursAgo = secondsAgo / hour

            if hoursAgo == 1 {
                localizedString = NSLocalizedString("%d hour ago", comment: "")
            } else {
                localizedString = NSLocalizedString("%d hours ago", comment: "")
            }

            output = String(format: localizedString, hoursAgo)

        case day..<week:

            let localizedString: String
            let daysAgo = secondsAgo / day

            if daysAgo == 1 {
                localizedString = NSLocalizedString("yesterday", comment: "")
            } else {
                localizedString = NSLocalizedString("%d days ago", comment: "")
            }

            output = String(format: localizedString, daysAgo)

        case week..<month:

            let localizedString: String
            let weeksAgo = secondsAgo / week

            if weeksAgo == 1 {
                localizedString = NSLocalizedString("last week", comment: "")
            } else {
                localizedString = NSLocalizedString("%d weeks ago", comment: "")
            }

            output = String(format: localizedString, weeksAgo)

        case month..<year:

            let localizedString: String
            let monthsAgo = secondsAgo / month

            if monthsAgo == 1 {
                localizedString = NSLocalizedString("last month", comment: "")
            } else {
                localizedString = NSLocalizedString("%d months ago", comment: "")
            }

            output = String(format: localizedString, monthsAgo)

        default:

            let localizedString: String
            let yearsAgo = secondsAgo / year

            if yearsAgo == 1 {
                localizedString = NSLocalizedString("last year", comment: "")
            } else {
                localizedString = NSLocalizedString("%d years ago", comment: "")
            }

            output = String(format: localizedString, yearsAgo)

        }

        return output
    }
}
