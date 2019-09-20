//
//  StatsTableViewController.swift
//  budJet
//
//  Created by neko on 26.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import BetterSegmentedControl

class StatsViewController: UIViewController {
    
    private var isIncome = false
    private var isCurrentMonth = true
    
    @IBOutlet weak var calendarView: UIView!
    var periodArray: [Date] = [Date]()
    var calendarViewController: CalendarViewController!
    
    @IBOutlet weak var typeSwitch: BetterSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var periodAmountLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var statsView: UIView!
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func initCalendarViewController() {
        if calendarViewController == nil {
            calendarViewController = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
            addChild(calendarViewController)
            calendarViewController.didMove(toParent: self)
            calendarViewController.dataSource = self
            calendarViewController.delegate = self
            
            let calendarControllerView = calendarViewController.view
            calendarView.insertSubview(calendarControllerView!, at: 0)
            calendarControllerView?.snp.makeConstraints({ (make) in
                make.top.equalTo(calendarView)
                make.leading.equalTo(calendarView)
                make.trailing.equalTo(calendarView)
                make.bottom.equalTo(calendarView)
            })
            
            topStackView.sendSubviewToBack(calendarView)
            
            calendarViewController.setClearButtonVisible(true)
            calendarViewController.calendarView.isRangeSelectionUsed = true
            calendarViewController.calendarView.allowsMultipleSelection = true
        }
    }
    
    private func toggleCalendar() {
        if calendarView.isHidden {
            calendarViewController.rebuildColors()
            UIView.animate(withDuration: 0.7, delay: 0,
                           usingSpringWithDamping: 0.9, initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.calendarView.isHidden = false
                            self.statsView.layer.shadowOpacity = 0.3
                            self.navigationView.layer.shadowOpacity = 0.3
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.statsView.layer.shadowOpacity = 0.0
                self.navigationView.layer.shadowOpacity = 0.0
            }
            UIView.animate(withDuration: 0.7, delay: 0,
                           usingSpringWithDamping: 0.9, initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.calendarView.isHidden = true
            })
        }
    }
    
    @IBAction func selectDateRangeAction(_ sender: Any) {
        toggleCalendar()
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Record> = {
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = getPredicate()
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHelper.coreDataManager.managedObjectContext, sectionNameKeyPath: "daySectionIdentifier", cacheName: nil)
        
        return fetchedResultsController
    }()
    
    private func setCurrentMonthPeriod() {
        isCurrentMonth = true
        let today = Date()
        let firstDay = today.firstDayOfMonth.start(of: .day)
        periodArray = Date.generateDateRange(from: firstDay, to: today)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCurrentMonthPeriod()

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            
        }

        self.configurePeriodLabel()

        navigationView.layer.shadowColor = UIColor(colorWithHexValue: 0x979797).cgColor
        navigationView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        navigationView.layer.shadowRadius = 1.0
        navigationView.layer.shadowOpacity = 0.0
        
        statsView.layer.shadowColor = UIColor(colorWithHexValue: 0x979797).cgColor
        statsView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        statsView.layer.shadowRadius = 1.0
        statsView.layer.shadowOpacity = 0.0
        
        typeSwitch.segments = LabelSegment.segments(withTitles: [NSLocalizedString("Expense", comment: ""), NSLocalizedString("Income", comment: "")],
                                                    normalFont: UIFont(name: "SFProText-Light", size: 13.0)!,
                                                    normalTextColor: .white,
                                                    selectedFont: UIFont(name: "SFProText-Light", size: 13.0)!,
                                                    selectedTextColor: .black)

        tableView.register(UINib(nibName: "DateSectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "DateSectionHeader")
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 85.0

//        self.initCalendarViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initCalendarViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        
        if sender.index == 0 {
            sender.backgroundColor = UIColor(colorWithHexValue: 0xCC6555)
            isIncome = false
        } else {
            sender.backgroundColor = UIColor(colorWithHexValue: 0x55CC96)
            isIncome = true
        }
        
        self.fetchedResultsController.fetchRequest.predicate = getPredicate()
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        configurePeriodLabel()
        if calendarViewController != nil && !calendarView.isHidden {
            calendarViewController.rebuildColors()
        }
    }
    
    func checkDataAvailable(_ amount: Float) {
        if amount > 0.0 {
            noDataLabel.text = nil
            tableView.isHidden = false
            noDataLabel.isHidden = true
        } else {
            noDataLabel.text = isIncome ? NSLocalizedString("No incomes data for selected period", comment: "") : NSLocalizedString("No expenses data for selected period", comment: "")
            tableView.isHidden = true
            noDataLabel.isHidden = false
        }
    }
    
    private func amountForCurrentPeriod() -> Float  {
        var totalAmount: Float = 0.0
        if let objects = fetchedResultsController.fetchedObjects {
            for record in objects {
                totalAmount += record.ammount
            }
        }
        return totalAmount
    }
    
    private func configurePeriodLabel() {
            if !isCurrentMonth {
                let template = "yyMMdd"
                let currentLocaleDateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = currentLocaleDateFormat
                let startDate = dateFormatter.string(from: periodArray.min()!)
                let endDate = dateFormatter.string(from: periodArray.max()!)
                if startDate == endDate {
                    periodLabel.text = String(format: "%@ ", startDate)
                } else {
                    periodLabel.text = String(format: "%@ - %@", startDate, endDate)
                }
            } else {
                periodLabel.text = NSLocalizedString("Current month", comment: "")
            }

        periodAmountLabel.textColor = UIColor(colorWithHexValue: isIncome ? 0x55CC96 : 0xCC6555)
        let amount = amountForCurrentPeriod()
        if amount > 0.0 {
            periodAmountLabel.text = amount.formattedWithSeparatorAndCurrency
        } else {
            periodAmountLabel.text = "--"
        }
        checkDataAvailable(amount)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditItemSegue" {
            let indexPath: IndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)! as IndexPath
            let controller = segue.destination as! AddRecordViewController
            controller.delegate = self
            controller.editRecord = fetchedResultsController.object(at: indexPath)
        }
    }
    
}

extension StatsViewController: AddRecordDelegate {
    
    func didCancel(controller: AddRecordViewController) {
        
    }
    
    func didFinishWithSuccess(controller: AddRecordViewController, record: Record) {
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
            configurePeriodLabel()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChartData"), object: nil)
            //Synchronizer.startSync()
        } catch {
            
        }
    }
    
}

extension StatsViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let item = fetchedResultsController.object(at: indexPath)
        let deleteAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            CoreDataHelper.removeItemWithId(item.id, completion: { (success) in
                if success {
                    do {
                        tableView.beginUpdates()
                        try self.fetchedResultsController.performFetch()
                        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
                            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                        } else {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        let headerView = tableView.headerView(forSection: indexPath.section) as! DateSectionHeader
                        var sectionValue: Float = 0.0
                        for record in (self.fetchedResultsController.sections?[indexPath.section].objects)! as! [Record] {
                            sectionValue += record.ammount
                        }

                        headerView.amountLabel.text = sectionValue.formattedWithSeparator
                        tableView.endUpdates()
                        self.configurePeriodLabel()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadChartData"), object: nil)
                        //Synchronizer.startSync()
                    } catch {
                        
                    }
                }
            })
        }
        
        deleteAction.hidesWhenSelected = false
        deleteAction.backgroundColor = UIColor.white
        deleteAction.title = nil
        deleteAction.image = UIImage(named: "Trash-circle")
        
        return [deleteAction]
    }
    
}
extension StatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = DateSectionHeader.instanceFromNib() as! DateSectionHeader
        
        var sectionTitle: String?
        var sectionValue: Float = 0.0
        if let sectionIdentifier = fetchedResultsController.sections?[section].name {
            for record in (fetchedResultsController.sections?[section].objects)! as! [Record] {
                sectionValue += record.ammount
            }
            if let numericSection = Int(sectionIdentifier) {
                let year = numericSection / 10000
                let month = (numericSection / 100) % 100
                let day = numericSection % 100
                
                var components = DateComponents()
                components.calendar = Calendar.current
                components.day = day
                components.month = month
                components.year = year
                
                let calendar = Calendar.current
                let currentComponents = calendar.dateComponents([.year], from: Date())
                
                if let date = components.date {
                    if currentComponents.year != components.year {
                        sectionTitle = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                    } else {
                        if date.isToday { sectionTitle = NSLocalizedString("Today", comment: "") }
                        else if date.isYesterday { sectionTitle = NSLocalizedString("Yesterday", comment: "") }
                        else {
                            sectionTitle = headerView.setDate(date)
                        }
                    }
                }
            }
        }
        
        headerView.amountLabel.text = sectionValue.formattedWithSeparator
        
        headerView.titleLabel.text = sectionTitle
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StatsViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCellIdentifier", for: indexPath) as! ItemTableViewCell
        
        let item = self.fetchedResultsController.object(at: indexPath)
        cell.item = item
        cell.delegate = self
        
//        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : UIColor(colorWithHexValue: 0xFBFBFB)
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : UIColor(colorWithHexValue: 0xFBFBFB)
        cell.contentView.backgroundColor = UIColor.white
        cell.backgroundColor = UIColor.white

        return cell
    }
    
}

extension StatsViewController: CalendarViewControllerDataSource {
    func selectedDateBackgroundColor() -> UIColor {
        if isIncome {
            return UIColor(colorWithHexValue: 0x55CC96, alpha: 0.9)
        } else {
            return UIColor(colorWithHexValue: 0xCC6555, alpha: 0.9)
        }
    }
    
    func selectedDate() -> Date {
        return Date()
    }
}

extension StatsViewController: CalendarViewControllerDelegate {
    
    func didSelectDate(_ date: Date) {

    }
    
    func shouldUpdatePeriodInfo(calendarController: CalendarViewController, selectedDates: [Date]) {
        if selectedDates.count == 0 {
            setCurrentMonthPeriod()
        } else {
            isCurrentMonth = false
            periodArray = selectedDates
        }
        fetchedResultsController.fetchRequest.predicate = getPredicate()
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        configurePeriodLabel()
    }
    
    func didTapClearButton(calendarController: CalendarViewController) {
        toggleCalendar()
        setCurrentMonthPeriod()
        fetchedResultsController.fetchRequest.predicate = getPredicate()
        do {
            try self.fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        configurePeriodLabel()
    }
    
    func didTapDoneButton(calendarController: CalendarViewController, selectedDates: [Date]) {
        toggleCalendar()
    }
    
    func getPredicate() -> NSPredicate {
        var predicate: NSPredicate!
        if var startDate = periodArray.first, var endDate = periodArray.last {
            startDate.hour(0)
            startDate.minute(0)
            startDate.second(0)
            
            endDate.hour(23)
            endDate.minute(59)
            endDate.second(59)
            predicate = NSPredicate(format: "income == %@ AND (date >= %@ AND date =< %@)", NSNumber(booleanLiteral: isIncome), startDate as NSDate, endDate as NSDate)
        } else {
            predicate = NSPredicate(format: "income == %@", NSNumber(booleanLiteral: isIncome))
        }
        return predicate
    }
    
}
