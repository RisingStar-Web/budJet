//
//  CalendarViewController.swift
//  budJet
//
//  Created by neko on 05.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import JTAppleCalendar
import DateToolsSwift

protocol CalendarViewControllerDelegate: class {
    func didSelectDate(_ date: Date)
    func didTapDoneButton(calendarController: CalendarViewController, selectedDates: [Date])
    func didTapClearButton(calendarController: CalendarViewController)
    func shouldUpdatePeriodInfo(calendarController: CalendarViewController, selectedDates: [Date])
}

protocol CalendarViewControllerDataSource: NSObjectProtocol {
    func selectedDateBackgroundColor() -> UIColor
    func selectedDate() -> Date
}

class CalendarViewController: UIViewController {

    weak var dataSource: CalendarViewControllerDataSource?
    weak var delegate: CalendarViewControllerDelegate?
    
    var prePostVisibility: ((CellState, CalendarCell?)->())?
    var firstDate: Date?
    private var isPeriodSelected = false
    
    let outsideMonthColor = UIColor(colorWithHexValue: 0xB7B7B7, alpha: 0.4)
    let monthColor = UIColor(colorWithHexValue: 0x444444)
    let selectedMonthColor = UIColor(colorWithHexValue: 0xffffff)
    let insideMonthBackColor = UIColor(colorWithHexValue: 0xffffff, alpha: 0.0)
    
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    
    let formatter = DateFormatter()

    @IBOutlet var weakDayNames: [UILabel]!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var currentMonth: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.delegate?.didTapDoneButton(calendarController: self, selectedDates: self.calendarView.selectedDates)
    }

    @IBAction func clearButtonAction(_ sender: UIButton) {
        isPeriodSelected = false
        self.delegate?.didTapClearButton(calendarController: self)
    }

    func rebuildColors() {
        currentMonth.textColor = dataSource?.selectedDateBackgroundColor()
        calendarView.reloadDates(calendarView.selectedDates)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearButton.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
        doneButton.setTitle(NSLocalizedString("Done", comment: ""), for: .normal)

        for weakDayLabel in weakDayNames {
            switch weakDayLabel.text {
            case "Mon":
                weakDayLabel.text = NSLocalizedString("Mon", comment: "")
            case "Tue":
                weakDayLabel.text = NSLocalizedString("Tue", comment: "")
            case "Wed":
                weakDayLabel.text = NSLocalizedString("Wed", comment: "")
            case "Thu":
                weakDayLabel.text = NSLocalizedString("Thu", comment: "")
            case "Fri":
                weakDayLabel.text = NSLocalizedString("Fri", comment: "")
            case "Sat":
                weakDayLabel.text = NSLocalizedString("Sat", comment: "")
            default:
                weakDayLabel.text = NSLocalizedString("Sun", comment: "")
            }
        }
        calendarView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCell")
        currentMonth.textColor = dataSource?.selectedDateBackgroundColor()
        setupCalendarView()

        calendarView.scrollToDate((dataSource?.selectedDate())!, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: .none, extraAddedOffset: 0.0)
    }

    func setClearButtonVisible(_ isVisible: Bool) {
        clearButton.isHidden = !isVisible
    }
    
    func setupCalendarView() {
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        let width = UIScreen.main.bounds.width
        let cellSize = CGFloat(width / 7)
        calendarView.cellSize = cellSize
        calendarView.visibleDates { (visibleDates) in
            self.setupViewOfCalendar(from: visibleDates)
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo != .thisMonth || cellState.date.isLater(than: Date()) {
                validCell.dateLabel.textColor = outsideMonthColor
            } else {
                validCell.dateLabel.textColor = monthColor
            }
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCell else { return }
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = dataSource?.selectedDateBackgroundColor()
        } else {
            validCell.selectedView.isHidden = true
        }
        validCell.backgroundColor = insideMonthBackColor
    }

    func setupViewOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        let template = "MMMyyy"
        let currentLocaleDateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)!
        self.formatter.dateFormat = currentLocaleDateFormat

        self.currentMonth.text = self.formatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hidePrepost() {
        prePostVisibility = {state, cell in
            if state.dateBelongsTo == .thisMonth {
                cell?.isHidden = false
            } else {
                cell?.isHidden = true
            }
        }
        calendarView.reloadData()
    }

}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: String(CoreDataHelper.getEarlyestDate().year) + "-01-01")
        let endDate = formatter.date(from: Date().format(with: "yyyy-MM-dd"))
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!, firstDayOfWeek: .monday, hasStrictBoundaries: true)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {

    func configureCellStates(cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        (cell as! CalendarCell).selectedView.layer.cornerRadius = (cell as! CalendarCell).selectedView.frame.size.width / 2.0
        if date.isLater(than: Date()) {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCellStates(cell: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        
        configureCellStates(cell: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        //prePostVisibility?(cellState, cell)

        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if isPeriodSelected && calendarView.selectedDates.count > 1 && (date.isLater(than: calendarView.selectedDates.last!) || date.isEarlier(than: calendarView.selectedDates.first!)) {
            firstDate = nil
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            isPeriodSelected = false
        }
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if calendarView.isRangeSelectionUsed {
            if firstDate != nil {
                if firstDate!.isLater(than: date) {
                    calendarView.selectDates(from: date, to: firstDate!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                    firstDate = date
                } else {
                    calendarView.selectDates(from: firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                }
                delegate?.shouldUpdatePeriodInfo(calendarController: self, selectedDates: calendarView.selectedDates)
                isPeriodSelected = true
            } else {
                firstDate = date
            }

            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            delegate?.shouldUpdatePeriodInfo(calendarController: self, selectedDates: calendarView.selectedDates)

        } else {
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            delegate?.didSelectDate(date)
        }
    }

    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        if calendarView.isRangeSelectionUsed && cellState.selectionType == .userInitiated {
            switch cellState.selectedPosition() {
            case .middle:
                calendarView.deselectDates(from: 1.days.later(than: date), to: calendar.selectedDates.max()!, triggerSelectionDelegate: false)
                delegate?.shouldUpdatePeriodInfo(calendarController: self, selectedDates: calendar.selectedDates)
                return false
            default:
                return true
            }
        }
 
        return true
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if calendar.selectedDates.count == 0 {
            firstDate = nil
        }
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        delegate?.shouldUpdatePeriodInfo(calendarController: self, selectedDates: calendar.selectedDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.visibleDates { (visibleDates) in
            if let date = visibleDates.monthDates.last?.date {
                let template = "MMMyyy"
                let currentLocaleDateFormat = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)!
                self.formatter.dateFormat = currentLocaleDateFormat
                self.currentMonth.text = self.formatter.string(from: date)
            }
        }
    }
}
