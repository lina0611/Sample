//
//  LGYear.swift
//  ExpenseTracker
//
//  Created by Lina Gao on 7/17/19.
//  Copyright © 2019 Lina Gao. All rights reserved.
//

import Foundation

class LGYear {

    /// An array of month. Start from January to December.
    var monthArray = [LGMonth]()

    var yearInStringFormat = ""
    // MARK: - Public functions

    /// Store all records in this year
    func store(allRecords: [LGRecord]) {
        divideRecordsIntoTwelveMonth(allRecords)
    }

    /// Store all incomes in this year
    func store(allIncomes: [Income]) {
        divideIncomesIntoTwelveMonth(allIncomes)
    }

    init() {
        generateEmptyMonths()
    }

    init(year: String, dictionary: [String: AnyObject]) {
        generateEmptyMonths()
        yearInStringFormat = year

        // Get Spending
        if let spendings = dictionary["spending"] as? [String: AnyObject] {
            // Convert dictionary to LGRecord
            let spendingArray = spendings.compactMap { record -> LGRecord in
                guard let value = record.value as? [String: AnyObject] else {
                    preconditionFailure("No value in Record")
                }
                return LGRecord(spendingDic: value, uid: record.key)
            }
            store(allRecords: spendingArray)
        }

        // Get Income
        if let incomes = dictionary["income"] as? [String: AnyObject] {
            let incomeArray = incomes.compactMap { income -> Income in
                guard let value = income.value as? [String: AnyObject] else {
                    preconditionFailure("No value in Record")
                }
                return Income(incomeDic: value, uid: income.key)
            }
            store(allIncomes: incomeArray)
        }
    }

    // MARK: - Public functions

    /// Total Income
    func totalIncome() -> Float {
        return monthArray.reduce(0) { $0 + $1.totalIncome() }
    }

    func totalIncomeInStringFormat() -> String {
        return String.doubleDigit(totalIncome())
    }

    /// Total Spending
    func totalSpending() -> Float {
        return monthArray.reduce(0) { $0 + $1.totalSpending() }
    }

    func totalSpendingInStringFormat() -> String {
        return String.doubleDigit(totalSpending())
    }

    /// Remaining Balance
    func totalBalance() -> Float {
        return totalIncome() - totalSpending()
    }

    // MARK: - Pivate functions

    /// Generate empty months
    private func generateEmptyMonths() {
        var monthCollector = [LGMonth]()
        for index in 0...11 {
            guard let monthType = MonthType(rawValue: index) else {
                preconditionFailure("Unable to get MonthType")
            }
            let month = LGMonth(monthType: monthType)
            monthCollector.append(month)
        }
        monthArray = monthCollector
    }

    /// Divide records into 12 months
    private func divideRecordsIntoTwelveMonth(_ allRecords: [LGRecord]) {
        monthArray.forEach { month in
            let filteredRecords = allRecords.filter {
                month.monthType == getMonthTypeFrom(date: $0.date)
            }
            month.store(records: filteredRecords)
        }
    }

    /// Divide incomes into 12 months
    private func divideIncomesIntoTwelveMonth(_ incomes: [Income]) {
        monthArray.forEach { month in
            let filteredIncomes = incomes.filter {
                month.monthType == getMonthTypeFrom(date: $0.date)
            }
            month.incomeArray = filteredIncomes.sorted { DateFormatter.fullDateFormatter().string(from: $0.date) > DateFormatter.fullDateFormatter().string(from: $1.date) }
        }
    }

    /// Get the Month type from a given date
    ///
    /// - Parameter date: Target Date e.g. 12/25/2019
    /// - Returns: Month type belongs to this date e.g. December
    private func getMonthTypeFrom(date: Date) -> MonthType {
        let month = Calendar.current.component(.month, from: date)
        let index = month - 1
        guard let monthType = MonthType(rawValue: index) else {
            preconditionFailure("Unable to get MonthType Enum")
        }
        return monthType
    }
}
