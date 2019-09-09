//
//  FireBaseManager.swift
//  ExpenseTracker
//
//  Created by Lina Gao on 6/23/19.
//  Copyright © 2019 Lina Gao. All rights reserved.
//

import Firebase
import Foundation
import UIKit

/// This class is used for managing data storage in fireablese
class FireBaseManager {

    private enum Constants {
        static let userEventsKey: String = "user-events"
        /// Expect `userUid` and `yearKey`
        static let saveRecordReferencePath: String = "user-events/%@/%@/spending"

        /// Expect `userUid` and `yearKey`
        static let saveIncomeReferencePath: String = "user-events/%@/%@/income"

        /// Expect `userUid`
        static let fetchRecordReferencePath: String = "user-events/%@"
    }

    func saveRecord(_ record: LGRecord, _ user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        let yearKey = String.yearInStringFormatFrom(date: record.date)
        let referencePath = String(format: Constants.saveRecordReferencePath, userUid, yearKey)
        let userRef = Database.database().reference(withPath: referencePath).childByAutoId()

        userRef.setValue(record.toDictionary()) { error, _ in
            completion(error == nil)
        }
    }

    func saveIncome(_ income: Income, _ user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        let yearKey = String.yearInStringFormatFrom(date: income.date)
        let referencePath = String(format: Constants.saveIncomeReferencePath, userUid, yearKey)
        let userRef = Database.database().reference(withPath: referencePath).childByAutoId()

        userRef.setValue(income.toDictionary()) { error, _ in
            completion(error == nil)
        }
    }

    /// This function returns an array of all years
    func fetchData(completionBlock: @escaping (_ records: [LGYear]?) -> Void) {
        let userUid = Auth.auth().currentUser!.uid
        Database.database().reference(withPath: String(format: Constants.fetchRecordReferencePath, userUid)).queryOrderedByKey().observe(.value) { snapshot in
            guard let years = snapshot.value as? [String: AnyObject] else {
                return completionBlock(nil)
            }

            let yearsArray = years.compactMap {year -> LGYear in
                guard let value = year.value as? [String: AnyObject] else {
                    preconditionFailure("Year Dictionary doesn't have value")
                }
                return LGYear(year: year.key, dictionary: value)
            }
            return completionBlock(yearsArray)
        }
    }

    /// This function remove value from firebase
    func removeRecordFromDataBase(_ record: LGRecord, _ user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        let yearKey = String.yearInStringFormatFrom(date: record.date)
        let referencePath = String(format: Constants.saveRecordReferencePath, userUid, yearKey)
        let userRef = Database.database().reference(withPath: referencePath).child(record.uid)

        userRef.removeValue { error, _ in
            completion(error == nil)
        }
    }

    /// This function remove value from firebase
    func removeIncomeFromDataBase(_ income: Income, _ user: UserModel, completion: @escaping (_ success: Bool) -> Void) {
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        let yearKey = String.yearInStringFormatFrom(date: income.date)
        let referencePath = String(format: Constants.saveIncomeReferencePath, userUid, yearKey)
        let userRef = Database.database().reference(withPath: referencePath).child(income.uid)

        userRef.removeValue { error, _ in
            completion(error == nil)
        }
    }
}
