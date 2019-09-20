//
//  ViewController.swift
//  budJet
//
//  Created by neko on 23.09.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import Charts
import CoreData

class MainViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var incomeTitleLabel: UILabel!
    @IBOutlet weak var expenceTitleLabel: UILabel!
    @IBOutlet weak var incomeValueLabel: UILabel!
    @IBOutlet weak var expenceValueLabel: UILabel!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var monthTitleLabel: UILabel!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var prevMonthButton: UIButton!
    
    var incomeValues = [PieChartDataEntry]()
    var outgoValues = [PieChartDataEntry]()

    var totalIncome: Float = 0.0
    var totalExpence: Float = 0.0
    var statsMonth = Date()
    var dataSet: PieChartDataSet!
    var pieChartData: PieChartData!
    var earliestDate = CoreDataHelper.getEarlyestDate()
    
    var isIncome = false
    
    @IBOutlet weak var pieChart: PieChartView!

    private func generateTestRecords(count: Int, startDate: Date, endDate: Date) {

        func getRandomType(income: Bool) -> Types {
            let fetchRequest: NSFetchRequest<Types> = Types.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "income == %@", NSNumber(booleanLiteral: income))
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHelper.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }

            return fetchedResultsController.fetchedObjects![Int.random(0, (fetchedResultsController.fetchedObjects?.count)! - 1)]
        }
        
        for _ in 1...count {
            let rndDate = Date.random(between: startDate, and: endDate)
            
            let entity =  NSEntityDescription.entity(forEntityName: "Record",in:CoreDataHelper.coreDataManager.managedObjectContext)
            let record = Record(entity: entity!,insertInto: CoreDataHelper.coreDataManager.managedObjectContext)
            record.id = CoreDataHelper.getUniqueRecordID()
            //record.sync = Int16(SyncState.pending.rawValue)
            
            record.date = rndDate
            record.daySectionIdentifier = rndDate.daySectionIdentifier()
            record.comment = Int.random() % 3 == 0 ? "Test" : nil
            record.income = Int.random() % 6 == 0
            record.ammount = Float.random(record.income ? 1000.0 : 50.0, record.income ? 15000.0 : 4000.0)
            record.typers = getRandomType(income: record.income)
            
            do {
                try record.managedObjectContext?.save()
            }
            catch {
                
            }
        }
        reloadView()
    }
    
    func checkPrevNextButtons() {
        prevMonthButton.isEnabled = true
        nextMonthButton.isEnabled = true
        if earliestDate > 1.months.earlier(than: statsMonth).lastDayOfMonth {
            prevMonthButton.isEnabled = false
        }
        if 1.months.later(than: statsMonth).firstDayOfMonth > Date() {
            nextMonthButton.isEnabled = false
        }
    }
    
    @IBAction func prevMonthAction(_ sender: UIButton) {
        statsMonth = 1.months.earlier(than: statsMonth)
        setChartData()
    }
    
    @IBAction func nextMonthAction(_ sender: UIButton) {
        statsMonth = 1.months.later(than: statsMonth)
        setChartData()
    }
    
    @IBAction func typeSelectRecognizer(_ sender: UITapGestureRecognizer) {
        pieChart.centerAttributedText = nil
        pieChart.centerText = nil
        pieChart.clear()
        
        isIncome = sender.view?.tag == 0
        
        configureHeaderView()
        dataSet.values = isIncome ? incomeValues : outgoValues
        
        if dataSet.count == 0 {
            pieChartData = nil
        } else {
            pieChartData = PieChartData(dataSet: dataSet)
        }
        
        pieChart.data = pieChartData
        pieChart.legend.entries = [LegendEntry]()
        checkPrevNextButtons()
        checkDataAvailable()
    }
    
    @IBAction func profileAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ProfileSegue", sender: self)
    }

    func checkDataAvailable() {
        if pieChartData != nil {
            noDataLabel.text = nil
            pieChart.isHidden = false
            noDataLabel.isHidden = true
        } else {
            noDataLabel.text = isIncome ? NSLocalizedString("No incomes data for selected period", comment: "") : NSLocalizedString("No expenses data for selected period", comment: "")
            pieChart.isHidden = true
            noDataLabel.isHidden = false
        }
    }
    
    func configureHeaderView() {
        if self.isIncome {
            self.expenceValueLabel.textColor = UIColor(colorWithHexValue: 0x545454)
            self.expenceValueLabel.font = UIFont.init(name: "SFProText-Medium", size: 18.0)
            self.incomeValueLabel.textColor = UIColor(colorWithHexValue: 0x55CC96)
            self.incomeValueLabel.font = UIFont.init(name: "SFProText-Medium", size: 22.0)
        } else {
            self.expenceValueLabel.textColor = UIColor(colorWithHexValue: 0xFF3B30)
            self.expenceValueLabel.font = UIFont.init(name: "SFProText-Medium", size: 22.0)
            self.incomeValueLabel.textColor = UIColor(colorWithHexValue: 0x545454)
            self.incomeValueLabel.font = UIFont.init(name: "SFProText-Medium", size: 18.0)
        }
    }

    @objc func reloadView() {
        setChartData()
    }
    /*
    @objc func synchronizeData() {
        Synchronizer.syncGetNewItems { (success) in
            if success {
                self.setChartData()
            }
        }
    }
    */
    /*
    func showPinCodeView() {
        let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: "PinCodeView") as! PinCodeViewController
        pinCodeViewController.modalPresentationStyle = .overCurrentContext
        present(pinCodeViewController, animated: true, completion: nil)
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        incomeTitleLabel.text = NSLocalizedString("Income", comment: "")
        expenceTitleLabel.text = NSLocalizedString("Expense", comment: "")
        //Creating test records
        //generateTestRecords(count: 1000, startDate: 9.months.earlier, endDate: 1.days.earlier)
        
/*
        if AppData.isPinCodeOn() {
            showPinCodeView()
        }
*/
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name(rawValue: "ReloadChartData"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(synchronizeData), name: NSNotification.Name(rawValue: "ResyncChartData"), object: nil)

        //synchronizeData()
        
        pieChart.delegate = self
        pieChart.drawCenterTextEnabled = true
        pieChart.drawHoleEnabled = true
        pieChart.chartDescription = nil
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.drawInside = false
        configureHeaderView()

        setChartData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PieChart
    
    private func getChartEntryForItems(_ items: [Record]) -> PieChartDataEntry {
        var totalValue: Float32 = 0
        for item in items {
            totalValue += item.ammount
        }
        if (items.first?.income)! { totalIncome += Float(totalValue) }
        else { totalExpence += Float(totalValue) }
        
        let pieChartEntry = PieChartDataEntry(value: Double(totalValue), label: NSLocalizedString((items.first?.typers?.key)!, comment: ""))
        return pieChartEntry
    }
    
    func setChartData() {
        earliestDate = CoreDataHelper.getEarlyestDate()
        incomeValues.removeAll()
        outgoValues.removeAll()
        totalIncome = 0.0
        totalExpence = 0.0
        
        pieChart.rotationEnabled = false

        pieChart.centerAttributedText = nil
        pieChart.centerText = nil
        pieChart.clear()
        
        monthTitleLabel.text = statsMonth.monthTitle
        for type in CoreDataHelper.getTypesList(income: nil) {
            if type.income {
                if let items = CoreDataHelper.getItemsForType(type, startDate: statsMonth.firstDayOfMonth, endDate: statsMonth.lastDayOfMonth) {
                    incomeValues.append(getChartEntryForItems(items))
                }
            } else {
                if let items = CoreDataHelper.getItemsForType(type, startDate: statsMonth.firstDayOfMonth, endDate: statsMonth.lastDayOfMonth) {
                    outgoValues.append(getChartEntryForItems(items))
                }
            }
        }
        
        expenceValueLabel.text = totalExpence == 0 ? "--" : NumberFormatter.withSeparator.string(for: totalExpence)
        incomeValueLabel.text = totalIncome == 0 ? "--" : NumberFormatter.withSeparator.string(for: totalIncome)
        
        dataSet = PieChartDataSet(values: isIncome ? incomeValues : outgoValues, label: nil)
        
        dataSet.sliceSpace = 2.0
        dataSet.drawIconsEnabled = false
        
        var colors = [UIColor]()
        colors.append(contentsOf: ChartColorTemplates.pastel())
        colors.append(contentsOf: ChartColorTemplates.material())

        dataSet.colors = colors
        
        dataSet.valueFormatter = DefaultValueFormatter(formatter: NumberFormatter.withSeparator)
        dataSet.valueFont = UIFont(name: "SFProText-Regular", size: 10.0)!
        dataSet.valueTextColor = UIColor.white
        
        if dataSet.count == 0 {
            pieChartData = nil
        } else {
            pieChartData = PieChartData(dataSet: dataSet)
        }
        
        pieChart.data = pieChartData
        
        checkPrevNextButtons()
        configureHeaderView()
        checkDataAvailable()
        pieChart.legend.enabled = false
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        let centerString = (entry as! PieChartDataEntry).label! + "\n" + NumberFormatter.withSeparator.string(for: (entry as! PieChartDataEntry).value)!
        let attributedCenterText = NSAttributedString.init(string: centerString, attributes: [NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 16.0)!, NSAttributedString.Key.foregroundColor: UIColor(colorWithHexValue: 0x545454), NSAttributedString.Key.paragraphStyle: style])
        pieChart.centerAttributedText = attributedCenterText
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        pieChart.centerAttributedText = nil
        pieChart.centerText = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItemSegue" {
            let controller = segue.destination as! AddRecordViewController
            controller.delegate = self
        }
    }
}

extension MainViewController: AddRecordDelegate {
    
    func didCancel(controller: AddRecordViewController) { }
    
    func didFinishWithSuccess(controller: AddRecordViewController, record: Record) {
        reloadView()
    }
    
}
