//
//  YearMonthDay.swift
//  NASA-APOD
//
//  Created by Apeksha on 26/02/22.
//

import Foundation
public struct YearMonthDay {
  public let year: Int
  public let month: Int
  public let day: Int

  public init(year: Int, month: Int, day: Int) {
    self.year = year
    self.month = month
    self.day = day
  }

  public init(localTime date: Date) {
    let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
    year = components.year!
    month = components.month!
    day = components.day!
  }
  public static var today: YearMonthDay {
    return YearMonthDay(localTime: Date())
  }

  public func asDate() -> Date? {
    guard let date = Calendar.current.date(from: DateComponents(timeZone: .current, year: year, month: month, day: day))
    else {
      return nil
    }
    return date
  }
}

extension YearMonthDay: LosslessStringConvertible {
  public var description: String {
    String(format: "%04d-%02d-%02d", year, month, day)
  }
  public var longDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let date = asDate() {
            return dateFormatter.string(from: date)
        } else {
            return " "
        }
 }
  public init?(_ description: String) {
    let components = description.split(separator: "-")
    guard components.count == 3,
       let year = Int(components[0]),
       let month = Int(components[1]),
       let day = Int(components[2]) else {
      return nil
    }
    self.year = year
    self.month = month
    self.day = day
  }
}
