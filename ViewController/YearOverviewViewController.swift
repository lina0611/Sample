//
//  YearOverviewViewController.swift
//  ExpenseTracker
//
//  Created by Lina Gao on 8/5/19.
//  Copyright © 2019 Lina Gao. All rights reserved.
//

import Charts
import Firebase
import UIKit

class YearOverviewViewController: UIViewController {

    private enum Constants {
        static let estimatedRowHeight: CGFloat = 60
        static let roundViewTableCellHeight: CGFloat = 60
        static let emptySection: Int = 0
        static let singleSections: Int = 1
        static let oneRowInSection: Int = 1
    }

    private enum TableRow: Int, CaseIterable {
        case barChartRow = 0
        case incomeRow
        case expenseRow
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var previousButton: RoundButton!
    @IBOutlet private weak var nextButton: RoundButton!
    @IBOutlet private var noRecordView: UIView!

    private var dataManager = DataManager.shared
    private var currentYear: LGYear?

    // MARK: - Init

    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1),
                                                                        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
    }

    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: RoundViewTableViewCell.identifier, bundle: nil),
                           forCellReuseIdentifier: RoundViewTableViewCell.identifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchYear()
        updateButtonStatus()
    }

    // MARK: - Fetch Data

    private func fetchYear() {
        dataManager.fetchData { [weak self] _ in
            guard let self = self else { return }
            self.updateUI(year: self.dataManager.currYear)
        }
    }

    /// Update UI from `year`
    private func updateUI(year: LGYear?) {
        currentYear = year
        navigationItem.title = currentYear?.yearInStringFormat
        updateButtonStatus()
        tableView.reloadData()
    }

    // MARK: - @IBAction

    @IBAction private func tapPreviousButton(_ sender: Any) {
        dataManager.goToPreviousYear { [weak self] year in
            guard let self = self else { return }
            self.updateUI(year: year)
        }
    }

    @IBAction private func tapNextButton(_ sender: Any) {
        dataManager.goToNextYear { [weak self] year in
            guard let self = self else { return }
            self.updateUI(year: year)
        }
    }

    // MARK: - Configure Button

    private func updateButtonStatus() {
        nextButton.isHidden = !dataManager.showNextButtonInYearVC()
        previousButton.isHidden = !dataManager.showPreviousButtonInYearVC()
    }

    // MARK: - Get Different Cell

    private func getBarChartTableViewCell(tableView: UITableView) -> BarChartTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BarChartTableViewCell.identifier)as? BarChartTableViewCell else {
            preconditionFailure("Failed to dequeue BarChartTableViewCell")
        }
        return cell
    }

    private func getRoundViewTableViewCell(tableView: UITableView) -> RoundViewTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RoundViewTableViewCell.identifier) as? RoundViewTableViewCell else {
            preconditionFailure("Failed to dequeue RoundViewTableViewCell")
        }
        return cell
    }
}

extension YearOverviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.backgroundView = (currentYear == nil) ? noRecordView : nil
        return currentYear == nil ? Constants.emptySection : Constants.singleSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentYear == nil ? Constants.oneRowInSection : TableRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = TableRow(rawValue: indexPath.row) else {
            preconditionFailure("Faild to convert to Row Type")
        }

        switch row {
        case .barChartRow:
            let cell = getBarChartTableViewCell(tableView: tableView)
            if let currentYear = currentYear {
                cell.configure(with: currentYear)
            }
            return cell
        case .incomeRow:
            let cell = getRoundViewTableViewCell(tableView: tableView)
            if let currentYear = currentYear {
                cell.configure(with: currentYear, rowType: .incomeRow)
            }
            return cell
        case .expenseRow:
            let cell = getRoundViewTableViewCell(tableView: tableView)
            if let currentYear = currentYear {
                cell.configure(with: currentYear, rowType: .expenseRow)
            }
            return cell
        }
    }
}

extension YearOverviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = TableRow(rawValue: indexPath.row) else {
            preconditionFailure("Faild to convert to Row Type")
        }

        switch rowType {
        case .barChartRow:
            return UITableView.automaticDimension
        case .incomeRow, .expenseRow:
            return Constants.roundViewTableCellHeight
        }
    }
}
