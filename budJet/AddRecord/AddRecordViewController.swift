//
//  AddRecordViewController.swift
//  budJet
//
//  Created by neko on 01.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import BetterSegmentedControl
import SnapKit
import JTAppleCalendar

enum CellType: Int {
    case amount = 0, category, comment, date
}

protocol AddRecordDelegate: class {
    func didFinishWithSuccess(controller: AddRecordViewController, record: Record)
    func didCancel(controller: AddRecordViewController)
}

class AddRecordViewController: UIViewController, UITextFieldDelegate, CategoryCollectionViewDelegate {
    
    weak var delegate: AddRecordDelegate!
    
    var newRecord = NewRecord()
    
    var editRecord: Record! {
        didSet(record) {
            newRecord.comment = editRecord.comment
            newRecord.date = editRecord.date!
            newRecord.income = editRecord.income
            newRecord.value = editRecord.ammount
            newRecord.type = editRecord.typers
        }
    }
    
    var categoryViewController: CategoryCollectionViewController?
    var collectionView: UICollectionView?
    
    var calendarViewController: CalendarViewController!
//    var calendarView: UIView?
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Types> = {
        let fetchRequest: NSFetchRequest<Types> = Types.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "income == %@", NSNumber(booleanLiteral: newRecord.income))
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataHelper.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var typeSwitch: BetterSegmentedControl!
    @IBOutlet weak var ammountTitleLabel: UILabel!
    @IBOutlet weak var amountTextField: AmountTextField!
    @IBOutlet weak var currenceTitleLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!

    @IBOutlet weak var noteTextField: HoshiTextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func selectCategoryAction(_ sender: UIButton?) {

        if categoryViewController == nil {
            categoryViewController = CategoryCollectionViewController(nibName: "CategoryCollectionViewController", bundle: nil)
            categoryViewController?.delegate = self
            
            collectionView = categoryViewController?.collectionView
            collectionView?.layer.borderWidth = 0.5
            collectionView?.layer.cornerRadius = 4
            collectionView?.layer.borderColor = UIColor(colorWithHexValue: 0x646464, alpha: 0.4).cgColor
            collectionView?.clipsToBounds = true
            collectionView?.backgroundColor = UIColor.white
            categoryViewController?.typesList = fetchedResultsController.fetchedObjects!
            view.addSubview(collectionView!)
            
            collectionView!.snp.makeConstraints { make in
                make.top.equalTo(typeSwitch.snp.bottom).offset(10.0)
                make.leading.equalTo(view).offset(20.0)
                make.trailing.equalTo(view).offset(-20.0)
                make.bottom.equalTo(doneButton.snp.bottom).offset(-10.0)
            }
            
        } else {
            categoryViewController?.typesList = fetchedResultsController.fetchedObjects!
            categoryViewController?.collectionView?.reloadData()
        }
    }

    @IBAction func changeDateAction(_ sender: UIButton) {
        //IQKeyboardManager.shared.resignFirstResponder()
        hideCategoryView()
        calendarViewController = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
        calendarViewController.modalPresentationStyle = .overCurrentContext
        calendarViewController.dataSource = self
        calendarViewController.delegate = self
        calendarViewController.view.backgroundColor = .clear// UIColor(colorWithHexValue: 0x646464, alpha: 0.5)
        present(calendarViewController, animated: true, completion: nil)
        calendarViewController?.calendarView.isRangeSelectionUsed = false
        calendarViewController?.calendarView.selectDates(from: newRecord.date, to: newRecord.date, triggerSelectionDelegate: false)
    }

    @IBAction func doneButtonAction(_ sender: UIButton) {
        if amountTextField.text!.isEmpty || Double(amountTextField.text!) == 0.0 {
            Extras.showInfoAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Enter amount", comment: ""), buttonTitle: "OK", inController: self)
            return
        }
        if newRecord.type == nil {
            let actionSheetController: UIAlertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Select category", comment: ""), preferredStyle: .alert)
            actionSheetController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.selectCategoryAction(nil)
                    })
            present(actionSheetController, animated: true, completion: nil)
            return
        }
        
        let entity =  NSEntityDescription.entity(forEntityName: "Record",in:CoreDataHelper.coreDataManager.managedObjectContext)
        let record: Record

        if amountTextField.isFirstResponder { amountTextField.resignFirstResponder() }
        if noteTextField.isFirstResponder { noteTextField.resignFirstResponder() }

        if editRecord == nil {
            record = Record(entity: entity!,insertInto: CoreDataHelper.coreDataManager.managedObjectContext)
            record.id = CoreDataHelper.getUniqueRecordID()
            record.sync = Int16(SyncState.pending.rawValue)
        } else {
            record = editRecord
            record.sync = Int16(SyncState.pendingEdit.rawValue)
        }
        
        record.date = newRecord.date
        record.daySectionIdentifier = newRecord.date.daySectionIdentifier()
        record.typers = newRecord.type
        record.ammount = Float32(amountTextField.text!)!
        record.comment = noteTextField.text
        record.income = newRecord.income
        
        do {
            try record.managedObjectContext?.save()
            //Synchronizer.startSync()
            dismiss(animated: true, completion: nil)
            delegate?.didFinishWithSuccess(controller: self, record: record)
        }
        catch {
            
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        if amountTextField.isFirstResponder { amountTextField.resignFirstResponder() }
        if noteTextField.isFirstResponder { noteTextField.resignFirstResponder() }
        
        dismiss(animated: true) {
            self.delegate?.didCancel(controller: self)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hideCategoryView() {
        if categoryViewController != nil {
            collectionView?.removeFromSuperview()
            collectionView = nil
            categoryViewController = nil
        }
    }
    
    func didSelectCategoryAtIndexPath(_ indexPath: IndexPath) {
        typeDidSelect(type: fetchedResultsController.fetchedObjects![indexPath.item])
        hideCategoryView()
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                
                UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: options, animations: {
                    self.doneButtonBottomConstraint.constant = 0.0
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                let options = UIView.AnimationOptions(rawValue: UInt((userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double

                UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                    self.doneButtonBottomConstraint.constant = -keyboardHeight
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false

        noteTextField.placeholder = NSLocalizedString("Note", comment: "")
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        dateButton.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
        doneButton.setTitle(NSLocalizedString("Spend", comment: ""), for: .normal)
        ammountTitleLabel.text = NSLocalizedString("Amount", comment: "")
        currenceTitleLabel.text = AppData.currencySymbol
        categoryButton.setTitle(NSLocalizedString("Select category", comment: ""), for: .normal)
        
        categoryButton.imageView?.contentMode = .scaleAspectFit
        noteTextField.delegate = self
        
        typeSwitch.segments = LabelSegment.segments(withTitles: [NSLocalizedString("Expense", comment: ""), NSLocalizedString("Income", comment: "")],
                              normalFont: UIFont(name: "SFProText-Light", size: 13.0)!,
                              normalTextColor: .white,
                              selectedFont: UIFont(name: "SFProText-Light", size: 13.0)!,
                              selectedTextColor: .black)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        categoryButton.contentEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 10.0)
        categoryButton.titleEdgeInsets = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: -10.0)
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        if editRecord != nil {
            amountTextField.text = String(newRecord.value)
            if let comment = newRecord.comment, comment.endIndex.encodedOffset > 0 {
                noteTextField.text = newRecord.comment
            }
            for type in fetchedResultsController.fetchedObjects! {
                if type.id == newRecord.type?.id {
                    typeDidSelect(type: type)
                    break
                }
            }
            didSelectDate(newRecord.date)
        } else {
            newRecord = NewRecord()
            selectCategoryAction(categoryButton)
        }
        
        amountTextField.amountInputViewController?.delegate = self
        
        amountTextField.becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textField.resignFirstResponder()
            amountTextField.becomeFirstResponder()
            return false
        }
        
        return true
    }
    
    func typeDidSelect(type: Types) {
        newRecord.type = type
        categoryButton.setTitle(NSLocalizedString(type.key!, comment: ""), for: .normal)
        categoryButton.setImage(UIImage(named: type.key!), for: .normal)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        newRecord.type = nil
        categoryButton.setTitle(NSLocalizedString("Select category", comment: ""), for: .normal)
        categoryButton.setImage(nil, for: .normal)

        if sender.index == 0 {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.doneButton.backgroundColor = UIColor(colorWithHexValue: 0xCC6555)
            }) {(Bool) -> Void in
                
            }
            newRecord.income = false
            sender.backgroundColor = UIColor(colorWithHexValue: 0xCC6555)
            noteTextField.borderActiveColor = UIColor(colorWithHexValue: 0xCC6555)
            doneButton.setTitle(NSLocalizedString("Spend", comment: ""), for: .normal)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.doneButton.backgroundColor = UIColor(colorWithHexValue: 0x55CC96)
            }) {(Bool) -> Void in
                
            }
            newRecord.income = true
            sender.backgroundColor = UIColor(colorWithHexValue: 0x55CC96)
            noteTextField.borderActiveColor = UIColor(colorWithHexValue: 0x55CC96)
            doneButton.setTitle(NSLocalizedString("Deposit", comment: ""), for: .normal)
        }

        self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "income == %@", NSNumber(booleanLiteral: newRecord.income))
        do {
            try self.fetchedResultsController.performFetch()
            hideCategoryView()
            selectCategoryAction(categoryButton)
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        selectCategoryAction(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddRecordViewController: CalendarViewControllerDataSource {
    
    func selectedDateBackgroundColor() -> UIColor {
        if newRecord.income {
            return UIColor(colorWithHexValue: 0x55CC96, alpha: 0.9)
        } else {
            return UIColor(colorWithHexValue: 0xCC6555, alpha: 0.9)
        }
    }
    
    func selectedDate() -> Date {
        return newRecord.date
    }
    
}

extension AddRecordViewController: CalendarViewControllerDelegate {
    
    func shouldUpdatePeriodInfo(calendarController: CalendarViewController, selectedDates: [Date]) {
        
    }
    
    func didSelectDate(_ date: Date) {
        newRecord.date = date
        calendarViewController?.dismiss(animated: true, completion: nil)
        amountTextField.becomeFirstResponder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        if date.isToday {
            dateButton.setTitle(NSLocalizedString("Today", comment: ""), for: .normal)
        } else if date.isYesterday {
            dateButton.setTitle(NSLocalizedString("Yesterday", comment: ""), for: .normal)
        } else {
            dateButton.setTitle(dateFormatter.string(from: date), for: .normal)
        }
    }
    
    func didTapClearButton(calendarController: CalendarViewController) {
        
    }
    
    func didTapDoneButton(calendarController: CalendarViewController, selectedDates: [Date]) {
        calendarViewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddRecordViewController: AmountKeyboardViewControllerDelegate {
    func didTapNumber(_ number: String) {
        
    }
    
    func didAddDecimalNumber(_ number: String, position: Int) {
        
    }
    
    func didTapOperation(_ operation: Operation) {
        
    }
    
    func didTapDot() {
        
    }
    
    func didAddIntegerNumber(_ number: String) {
        hideCategoryView()
    }
}

struct NewRecord {
    var value: Float = 0.0
    var comment: String?
    var type: Types?
    var income = false
    var date = Date()
}
