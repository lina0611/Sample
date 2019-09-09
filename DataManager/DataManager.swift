//
//  DataManager.swift
//  ExpenseTracker
//
//  Created by Lina Gao on 6/23/19.
//  Copyright © 2019 Lina Gao. All rights reserved.
//

import Foundation

class DataManager {

    // MARK: - Public property

    /// Errors in DataManager
    enum DataManagerError: Error {
        case fetchRecordFailed
        case removeRecordFailed
        case fetchIncomeFailed
        case removeIncomeFailed
    }

    static let shared = DataManager()

    /// Selected month to display
    var currMonth: LGMonth? {
        guard let currYear = currYear else { return nil }
        return currYear.monthArray[currMonthIndex]
    }

    /// Selected year to display
    var currYear: LGYear? {
        return yearsArray.isEmpty ? nil : yearsArray[currYearIndex]
    }

    // MARK: - Private property

    /// Fire Base Manager
    private let fireBaseManager = FireBaseManager()

    /// All years stored on Fire Base
    private var yearsArray = [LGYear]()

    /// Displayed month index
    private var currMonthIndex: Int = {
        // Get initial index of month from current date
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        return month - 1
    }()

    /// Displayed year index
    private var currYearIndex = 0

    // MARK: - Public Functions

    func fetchData(completion: @escaping (_ success: Bool) -> Void) {
        fireBaseManager.fetchData { [weak self] years in
            guard let self = self else { return }
            if let years = years {
                // Sort years by year sequence
                self.yearsArray = years.sorted { $0.yearInStringFormat < $1.yearInStringFormat }
                self.currYearIndex = self.getCurrentYearIndex()
                completion(true)
            } else {
                // Remove old records from 'yearArray'
                self.yearsArray.removeAll()
                completion(false)
            }
        }
    }

    // MARK: - Save/Remove Functions

    func saveRecord(_ record: LGRecord, for user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        fireBaseManager.saveRecord(record, user) { success in
            completion(success)
        }
    }

    func saveIncome(_ income: Income, for user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        fireBaseManager.saveIncome(income, user) { success in
            completion(success)
        }
    }

    func removeRecord(_ record: LGRecord, _ user: UserModel, completion: @escaping (_ error: Error?, _ newMonth: LGMonth?) -> Void) {
        // Step 1: remove record from Firebase data base
        fireBaseManager.removeRecordFromDataBase(record, user) { [weak self] success in
            guard let self = self else { return }
            // If remove not success, return false, and empty `LGMonth`
            if success == false {
                completion(DataManagerError.removeRecordFailed, nil)
            }
            // Step 2: remove success, we need to fetch latest data
            self.fetchData { _ in
                completion(nil, self.currMonth)
            }
        }
    }

    func removeIncome(_ income: Income, _ user: UserModel, completion: @escaping (_ error: Error?, _ newMonth: LGMonth?) -> Void) {
        fireBaseManager.removeIncomeFromDataBase(income, user) { [weak self] success in
            guard let self = self else { return }

            if success == false {
                completion(DataManagerError.removeIncomeFailed, nil)
            }

            self.fetchData { _ in
                completion(nil, self.currMonth)
            }
        }
    }

    // MARK: - Next/Previous Functions

    func goToNextMonth(completion: @escaping (_ monthRecord: LGMonth?) -> Void) {
        if currMonthIndex == 11 {
            return
        }
        currMonthIndex += 1
        completion(currMonth)
    }

    func goToPreviousMonth(completion: @escaping (_ monthRecord: LGMonth?) -> Void) {
        if currMonthIndex == 0 {
            return
        }
        currMonthIndex -= 1
        completion(currMonth)
    }

    func goToNextYear(completion: @escaping (_ monthRecord: LGYear?) -> Void) {
        if currYearIndex == yearsArray.count - 1 || yearsArray.isEmpty {
            return
        }
        currYearIndex += 1
        completion(currYear)
    }

    func goToPreviousYear(completion: @escaping (_ monthRecord: LGYear?) -> Void) {
        if currYearIndex == 0 {
            return
        }
        currYearIndex -= 1
        completion(currYear)
    }

    func showNextButtonInOverviewVC() -> Bool {
        return currMonthIndex == 11 ? false : true
    }

    func showPreviousButtonInOverviewVC() -> Bool {
        return currMonthIndex == 0 ? false : true
    }

    func showNextButtonInYearVC() -> Bool {
        return currYearIndex == yearsArray.endIndex - 1 || yearsArray.isEmpty || yearsArray.count == 1 ? false : true
    }

    func showPreviousButtonInYearVC() -> Bool {
        return currYearIndex == 0 || yearsArray.isEmpty || yearsArray.count == 1 ? false : true
    }

    // MARK: - Private Functions

    private func getCurrentYearIndex() -> Int {
        // Always show the earliest year
        return yearsArray.isEmpty ? 0 : yearsArray.count - 1
    }
}
