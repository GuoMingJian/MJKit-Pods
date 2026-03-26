//
//  Date+Ext.swift
//  MJKit
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit

// MARK: ===== Date =====
public let mj_dateFormatter = DateFormatter()

private let mjDateFormatterLock = NSLock()

fileprivate func mjPerformWithSharedFormatter<R>(_ body: (DateFormatter) -> R) -> R {
    mjDateFormatterLock.lock()
    defer { mjDateFormatterLock.unlock() }
    return body(mj_dateFormatter)
}

public extension Date {
    // MARK: 获取当前日期 "yyyy-MM-dd"
    /// 获取当前日期 "yyyy-MM-dd"
    static func currentDateString(dateFormat: String? = nil) -> String {
        let newDF: String = dateFormat ?? MJ.yyyyMMdd
        return mjPerformWithSharedFormatter { df in
            df.dateFormat = newDF
            return df.string(from: Date())
        }
    }
    
    // MARK: Date -> String
    /// Date -> String
    static func dateToString(date: Date,
                             dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        mjPerformWithSharedFormatter { df in
            df.dateFormat = dateFormat
            return df.string(from: date)
        }
    }
    
    /// Date -> String
    static func dateToString(date: Date,
                             dateFormatter: DateFormatter? = nil) -> String {
        if let df = dateFormatter {
            return df.string(from: date)
        }
        return mjPerformWithSharedFormatter { df in
            df.dateStyle = .medium
            df.timeStyle = .none
            df.locale = Locale.current
            return df.string(from: date)
        }
    }
    
    // MARK: String -> Date
    /// String -> Date
    static func stringToDate(dateString: String,
                             dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        mjPerformWithSharedFormatter { df in
            df.dateFormat = dateFormat
            return df.date(from: dateString) ?? Date()
        }
    }
    
    /// String -> Date
    static func stringToDate(dateString: String,
                             dateFormatter: DateFormatter? = nil) -> Date {
        if let df = dateFormatter {
            return df.date(from: dateString) ?? Date()
        }
        return mjPerformWithSharedFormatter { df in
            df.dateStyle = .medium
            df.timeStyle = .none
            df.locale = Locale.current
            return df.date(from: dateString) ?? Date()
        }
    }
    
    // MARK: 时间戳 转 字符串
    /// 时间戳 转 字符串
    static func timestampToString(timestamp: Int,
                                  dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let newTimestamp = updateTimestamp(timestamp)
        let date = Date(timeIntervalSince1970: TimeInterval(newTimestamp))
        let dateString = dateToString(date: date, dateFormat: dateFormat)
        return dateString
    }
    
    /// 时间戳 转 字符串
    static func timestampToString(timestampStr: String,
                                  dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        var newTimestamp = timestampStr
        if newTimestamp.count > 10 {
            newTimestamp = (newTimestamp as NSString).substring(to: 10)
        }
        let timeInt: Int = Int(newTimestamp) ?? 0
        let date = Date(timeIntervalSince1970: TimeInterval(timeInt))
        let dateString = dateToString(date: date, dateFormat: dateFormat)
        return dateString
    }
    
    /// 时间戳 转 字符串
    static func timestampToString(timestamp: Int,
                                  dateFormatter: DateFormatter? = nil) -> String {
        let newTimestamp = updateTimestamp(timestamp)
        let date = Date(timeIntervalSince1970: TimeInterval(newTimestamp))
        var newDF: DateFormatter = getDateFormatter()
        if let dateFormatter = dateFormatter {
            newDF = dateFormatter
        }
        let dateString = dateToString(date: date, dateFormatter: newDF)
        return dateString
    }
    
    // MARK: 时间戳 转 date
    /// 时间戳 转 date
    static func timestampToDate(timestamp: Int) -> Date {
        let newTimestamp = updateTimestamp(timestamp)
        let date = Date(timeIntervalSince1970: TimeInterval(newTimestamp))
        return date
    }
    
    // MARK: 获取与当前年份相差值 (count:负数为前x年，正数为后x年)
    /// 获取与当前年份相差值 (count:负数为前x年，正数为后x年)
    static func newYearWithCount(date: Date,
                                 count: Int,
                                 dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let calendar = Calendar(identifier: .gregorian)
        guard let newDate = calendar.date(byAdding: .year, value: count, to: date) else {
            return ""
        }
        return dateToString(date: newDate, dateFormat: dateFormat)
    }
    
    // MARK: 获取与当前天数相差值 (count:负数为前x天，正数为后x天)
    /// 获取与当前天数相差值 (count:负数为前x天，正数为后x天)
    static func newDayWithCount(date: Date,
                                count: Int,
                                dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let calendar = Calendar(identifier: .gregorian)
        guard let newDate = calendar.date(byAdding: .day, value: count, to: date) else {
            return ""
        }
        return dateToString(date: newDate, dateFormat: dateFormat)
    }
    
    /// 获取与当前天数相差值 (count:负数为前x天，正数为后x天)
    static func newDayWithCount(date: Date,
                                count: Int,
                                dateFormatter: DateFormatter) -> String {
        let calendar = Calendar(identifier: .gregorian)
        guard let newDate = calendar.date(byAdding: .day, value: count, to: date) else {
            return ""
        }
        return dateToString(date: newDate, dateFormatter: dateFormatter)
    }
    
    // MARK: 获取与当前小时数相差值 (count:负数为前x小时，正数为后x小时)
    /// 获取与当前小时数相差值 (count:负数为前x小时，正数为后x小时)
    static func newHoursWithCount(date: Date,
                                  count: Int,
                                  dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let calendar = Calendar(identifier: .gregorian)
        guard let newDate = calendar.date(byAdding: .hour, value: count, to: date) else {
            return ""
        }
        return dateToString(date: newDate, dateFormat: dateFormat)
    }
    
    // MARK: 获取周几 (1-7; 1: Sunday 7: Saturday)
    /// 获取周几 (1-7; 1: Sunday 7: Saturday)
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    // MARK: 获取某一天所在的周一和周日
    /// 获取某一天所在「周」的起止（遵循 `Calendar.current` 的 `firstWeekday` 与周定义）
    static func getWeekTime(_ date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return (date, date)
        }
        let endInclusive = calendar.date(byAdding: .second, value: -1, to: interval.end) ?? interval.end
        return (interval.start, endInclusive)
    }
    
    // MARK: 获取日期在当月是第几天
    /// 指定日期在日历上对应的「日」分量（1–31），即当月第几天；若需该月总天数请用 `daysInMonth(date:)`
    static func getDayCount(date: Date = Date()) -> Int {
        Calendar.current.component(.day, from: date)
    }
    
    // MARK: 获取当月开始日期
    /// 当月开始日期
    static func startOfCurrentMonth(_ nowDay: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: nowDay)
        if let startOfMonth = calendar.date(from: components) {
            return startOfMonth
        }
        return nowDay
    }
    
    // MARK: 获取当月结束日期
    /// 获取当月结束日期
    static func endOfCurrentMonth(_ nowDay: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        // 获取当前月份的开始日期
        let currentMonth = calendar.dateComponents([.year, .month], from: nowDay)
        // 计算本月的开始日期
        guard let startOfMonth = calendar.date(from: currentMonth) else {
            // 如果计算失败，返回当前日期
            return nowDay
        }
        // 计算本月的结束日期
        if let endOfMonth = calendar.date(byAdding: components, to: startOfMonth) {
            return endOfMonth
        }
        // 如果无法计算结束日期，返回当前日期
        return nowDay
    }
    
    // MARK: 时间比较大小
    /// 是否大于传入date
    func isGreater(than date: Date) -> Bool {
        return self > date
    }
    
    /// 是否小于传入date
    func isSmaller(than date: Date) -> Bool {
        return self < date
    }
    
    /// 是否等于传入date
    func isEqual(to date: Date) -> Bool {
        return self == date
    }
    
    // MARK: 判断是否为今天
    /// 判断是否为今天
    func isToday() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        if dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day {
            return true
        }
        return false
    }
    
    // MARK: 判断是否为昨天
    /// 判断是否为昨天
    func isYesterday() -> Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    // MARK: 计算两个时间相差多少秒
    /// 计算两个时间相差多少秒
    func seconds(otherDate: Date) -> TimeInterval {
        return self.timeIntervalSince(otherDate)
    }
    
    // MARK: 秒转换成播放时间条的格式
    /// 时间条的显示格式
    enum MJTimeBarType {
        // 默认格式，如 9秒 -> 09; 66秒 -> 01:06;
        case normal
        case second
        case minute
        case hour
    }
    
    /// 秒转换成播放时间条的格式
    static func convertToPlayTime(seconds: Int,
                                  type: MJTimeBarType = .normal) -> String {
        if seconds <= 0 {
            return "00:00"
        }
        // 秒
        let second = seconds % 60
        if type == .second {
            return String(format: "%02d", seconds)
        }
        // 分钟
        var minute = Int(seconds / 60)
        if type == .minute {
            return String(format: "%02d:%02d", minute, second)
        }
        // 小时
        var hour = 0
        if minute >= 60 {
            hour = Int(minute / 60)
            minute = minute - hour * 60
        }
        if type == .hour {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        // normal 类型
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        if minute > 0 {
            return String(format: "%02d:%02d", minute, second)
        }
        return String(format: "%02d", second)
    }
    
    // MARK: 取得与当前时间的间隔差
    /// 间隔差类型
    enum MJAfterNowType {
        case now
        case minuteAgo
        case hourAgo
        case dayAgo
        case monthAgo
        case yearAgo
        
        public func toString() -> String {
            switch self {
                // 可以使用多语言
            case .now:
                return "just_now".mj_Localized()
            case .minuteAgo:
                return "minutes_ago".mj_Localized()
            case .hourAgo:
                return "hours_ago".mj_Localized()
            case .dayAgo:
                return "days_ago".mj_Localized()
            case .monthAgo:
                return "months_ago".mj_Localized()
            case .yearAgo:
                return "years_ago".mj_Localized()
            }
        }
    }
    
    /// 取得与当前时间的间隔差
    func convertToAfterNow() -> String {
        let timeInterval = Date().timeIntervalSince(self)
        if timeInterval < 0 {
            return MJAfterNowType.now.toString()
        }
        let interval = fabs(timeInterval)
        let i60 = interval / 60
        let i3600 = interval / 3600
        let i86400 = interval / 86400
        let i2592000 = interval / 2592000
        let i31104000 = interval / 31104000
        
        var time: String = ""
        if i3600 < 1 {
            let s = NSNumber(value: i60 as Double).intValue
            if s == 0 {
                time = MJAfterNowType.now.toString()
            } else {
                time = "\(s)\(MJAfterNowType.minuteAgo.toString())"
            }
        } else if i86400 < 1 {
            let s = NSNumber(value: i3600 as Double).intValue
            time = "\(s)\(MJAfterNowType.hourAgo.toString())"
        } else if i2592000 < 1 {
            let s = NSNumber(value: i86400 as Double).intValue
            time = "\(s)\(MJAfterNowType.dayAgo.toString())"
        } else if i31104000 < 1 {
            let s = NSNumber(value: i2592000 as Double).intValue
            time = "\(s)\(MJAfterNowType.monthAgo.toString())"
        } else {
            let s = NSNumber(value: i31104000 as Double).intValue
            time = "\(s)\(MJAfterNowType.yearAgo.toString())"
        }
        return time
    }
    
    // MARK: 获取某一年某一月的天数
    /// 获取某一年某一月的天数
    static func daysCount(year: Int,
                          month: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            // 判断是否为闰年
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            return isLeapYear ? 29 : 28
        default:
            fatalError("非法的月份: \(month)")
        }
    }
    
    // MARK: 获取传入date所在月份的天数
    /// 获取传入date所在月份的天数
    static func daysInMonth(date: Date) -> Int {
        let calendar = Calendar.current
        
        // 获取该月份的天数
        let numberOfDays: Int = calendar.range(of: .day, in: .month, for: date)?.count ?? 0
        return numberOfDays
    }
    
    // MARK: -
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp: String {
        let time = self.timeIntervalSince1970
        let timeString = String(format: "%0.f", time)
        return timeString
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var msTimeStamp: String {
        let time = self.timeIntervalSince1970 * 1000
        let timeString = String(format: "%0.f", time)
        return timeString
    }
    
    /// 从 Date 获取年份
    var year: Int {
        return Calendar.current.component(Calendar.Component.year, from: self)
    }
    
    /// 从 Date 获取年份
    var month: Int {
        return Calendar.current.component(Calendar.Component.month, from: self)
    }
    
    /// 从 Date 获取 日
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// 从 Date 获取 日
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// 从 Date 获取 分钟
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 从 Date 获取 秒
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    /// 从 Date 获取 毫秒
    var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    var formattedText: String {
        let calendarInstance = Calendar.current
        let dateFormatter = DateFormatter()
        let currentTime = Date()
        let timeDifference = calendarInstance.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: self,
            to: currentTime
        )
        
        let currentYearValue = calendarInstance.component(.year, from: currentTime)
        let targetYearValue = calendarInstance.component(.year, from: self)
        
        if currentYearValue != targetYearValue {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.string(from: self)
        }
        
        if !calendarInstance.isDateInToday(self) {
            dateFormatter.dateFormat = "MM-dd HH:mm"
            return dateFormatter.string(from: self)
        }
        
        if let hoursValue = timeDifference.hour, hoursValue >= 1 {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
        }
        
        if let minutesValue = timeDifference.minute, minutesValue >= 1 {
            return "\(minutesValue)" + " \("minutes_ago".mj_Localized())"
        }
        return "just_now".mj_Localized()
    }
}

public extension Date {
    // MARK: 当前时区
    /// 当前时区
    static func currentTimeZoneString() -> String {
        return TimeZone.current.identifier
    }
    
    /// 获取当前时间TimeZone
    static func getLocalTimeZone() -> String {
        let timeZoneIdentifier = TimeZone.current.identifier
        if let abbrev = TimeZone.abbreviationDictionary.first(where: { $0.value == timeZoneIdentifier })?.key {
            return abbrev
        }
        return timeZoneIdentifier
    }
    
    // MARK: 获取系统语言 string
    /// 获取系统语言 string
    static func getSystemLanguageIdentifier() -> String {
        let languageIdentifier: String = NSLocale.preferredLanguages.first ?? "en_US"
        return languageIdentifier
    }
    
    // MARK: 获取 DateFormatter
    /// 获取 DateFormatter
    static func getDateFormatter(timeZone: TimeZone? = nil) -> DateFormatter {
        mjPerformWithSharedFormatter { df in
            df.dateStyle = .medium
            df.timeStyle = .none
            df.locale = Locale.current
            df.timeZone = timeZone ?? .current
            return df
        }
    }
    
    /// 获取 DateFormatter
    static func getDateFormatter(timeZone: TimeZone,
                                 dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> DateFormatter {
        mjPerformWithSharedFormatter { df in
            df.dateStyle = .none
            df.timeStyle = .none
            df.locale = Locale.current
            df.timeZone = timeZone
            df.dateFormat = dateFormat
            return df
        }
    }
    
    // MARK: 获取 UTC DateFormatter
    /// 获取 UTC DateFormatter
    static func getUTCDateFormatter(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> DateFormatter {
        mjPerformWithSharedFormatter { df in
            df.dateStyle = .none
            df.timeStyle = .none
            df.locale = Locale.current
            df.timeZone = utcTimeZone()
            df.dateFormat = dateFormat
            return df
        }
    }
    
    /// UTC TimeZone
    static func utcTimeZone() -> TimeZone {
        let timeZone: TimeZone = NSTimeZone(abbreviation: "UTC") as? TimeZone ?? .current
        return timeZone
    }
    
    // MARK: string -> UTC date
    /// string -> UTC date
    static func getUTCDate(dateString: String,
                           dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        return getDateFrom(dateString: dateString, dateFormat: dateFormat, timeZone: utcTimeZone())
    }
    
    // MARK: date -> UTC date
    /// date -> UTC date
    static func getUTCDate(date: Date,
                           dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateString = getStringFrom(date: date, dateFormat: dateFormat, timeZone: utcTimeZone())
        let newDate = getDateFrom(dateString: dateString ?? "", dateFormat: dateFormat, timeZone: utcTimeZone())
        return newDate
    }
    
    // MARK: date -> UTC string
    /// date -> UTC string
    static func getUTCString(date: Date,
                             dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String? {
        return getStringFrom(date: date, dateFormat: dateFormat, timeZone: utcTimeZone())
    }
    
    static func getDateFrom(dateString: String,
                            dateFormat: String = "yyyy-MM-dd HH:mm:ss",
                            timeZone: TimeZone) -> Date? {
        mjPerformWithSharedFormatter { formatter in
            formatter.dateStyle = .none
            formatter.timeStyle = .none
            formatter.timeZone = timeZone
            formatter.locale = Locale(identifier: timeZone.identifier)
            formatter.dateFormat = dateFormat
            return formatter.date(from: dateString)
        }
    }
    
    static func getStringFrom(date: Date,
                              dateFormat: String = "yyyy-MM-dd HH:mm:ss",
                              timeZone: TimeZone) -> String? {
        mjPerformWithSharedFormatter { formatter in
            formatter.dateStyle = .none
            formatter.timeStyle = .none
            formatter.timeZone = timeZone
            formatter.locale = Locale(identifier: timeZone.identifier)
            formatter.dateFormat = dateFormat
            return formatter.string(from: date)
        }
    }
    
    // MARK: 时间戳（统一处理为10位，异常时为0）
    /// 时间戳（统一处理为10位，异常时为0）
    static func updateTimestamp(_ timestamp: Int) -> Int {
        var temp = "\(timestamp)"
        if temp.count > 10 {
            // 13位 转 10位
            temp = (temp as NSString).substring(to: 10)
        }
        let newTimestamp: Int = Int(temp) ?? 0
        return newTimestamp
    }
}
