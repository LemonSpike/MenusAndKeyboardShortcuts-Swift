/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Master view controller portion of UISplitViewController.
*/

import UIKit

class MasterViewController: UITableViewController, DetailItemDelegate {

    var tableItems = [TableItem]()
        
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    lazy var detailViewController: DetailViewController = {
        var returnDetailViewController = DetailViewController()
        if let splitViewController = view.window!.rootViewController as? UISplitViewController {
            if let detailNavigationController = splitViewController.viewControllers[1] as? UINavigationController {
                if let detailViewController = detailNavigationController.topViewController as? DetailViewController {
                    returnDetailViewController = detailViewController
                    returnDetailViewController.detailItemDelegate = self
                }
            }
        }
        return returnDetailViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
#if !targetEnvironment(macCatalyst)
        // For Mac Catalyst, you allow for the Edit menu and contextual menu for cut/copy/paste/delete.
        // For iOS, you use this edit button in the navigation bar for deleting table cells.
        navigationItem.leftBarButtonItem = editButtonItem
#endif
        
        let addButton =
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewDateObject(_:)))
        navigationItem.rightBarButtonItem = addButton

        /** Install the up and down arrow key commands to navigate through the table cells.
            Note that up and down key commands are automatically supported on Mac Catalyst.
        */
        let downArrowCommand =
            UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                         modifierFlags: [],
                         action: #selector(MasterViewController.downArrowAction(_:)))
        addKeyCommand(downArrowCommand)
        
        let upArrowCommand =
            UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                         modifierFlags: [],
                         action: #selector(MasterViewController.upArrowAction(_:)))
        addKeyCommand(upArrowCommand)
        
        // Install a delete key command to delete a table cell.
        let deleteCommand =
            UIKeyCommand(input: "\u{8}", // Apply the Unicode character input for backspace key.
                         modifierFlags: [],
                         action: #selector(MasterViewController.delete(_:)))
        addKeyCommand(deleteCommand)
        
        /** Install Command-N to this table view.
            Note: The discoverabilityTitle is used to display its command in the overlay window on the iPad when the command-key is held down.
            Note: If you are building and testing on the iPad Simulator make sure to select:
                    "Hardware -> Keyboard -> Send Keyboard Shortcuts to Device".
         */
        let newCommand =
            UIKeyCommand(title: NSLocalizedString("DateItemTitle", comment: ""),
                         image: nil,
                         action: #selector(MasterViewController.newAction(_:)),
                         input: "N",
                         modifierFlags: .command,
                         propertyList: nil)
        newCommand.discoverabilityTitle = NSLocalizedString("Command_N_DiscoveryTitle", comment: "")
        addKeyCommand(newCommand)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        super.viewWillAppear(animated)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if editing {
            // User tapped the Edit button, which removes the current table selection.
            detailViewController.detailItem = nil
        }
        super.setEditing(editing, animated: animated)
    }
    
    // MARK: - Selection Support
    
    private func selectDetailItem(indexPath: IndexPath) {
        detailViewController.detailItem = tableItems[indexPath.row]
    }
    
    private func selectRow(at indexPath: IndexPath) {
        // Make sure we have a row to select.
        if indexPath.row >= 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
            selectDetailItem(indexPath: indexPath)
        }
    }
    
    // MARK: - DetailItemDelegate
    
    func didUpdateItem(_ item: TableItem) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableItems[selectedIndexPath.row] = item
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
        }
    }
    
}

// MARK: - UITableViewDataSource

extension MasterViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = tableItems[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            detailViewController.detailItem = nil
            
            if tableView.numberOfRows(inSection: 0) == 0 {
                // No more cells to delete, so exit edit mode.
                setEditing(false, animated: true)
            }
        }
    }
    
}

// MARK: - UITableViewDelegate

extension MasterViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectDetailItem(indexPath: indexPath)
    }

}

// MARK: - UIResponder

extension MasterViewController {
    
    // Required if you want to use UIKeyCommands (up and down arrows) to work for iOS.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // The responder chain is asking us which commands you support.
    // Enable/disable certain Edit menu commands.
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(newAction(_:)) {
            // User wants to perform a "New" operation.
            return true
        } else {
            switch (tableView.indexPathForSelectedRow, action) {
            
            // These Edit commands are supported:
            case let (_?, action) where action == #selector(cut(_:)) ||
                                        action == #selector(copy(_:)) ||
                                        action == #selector(delete(_:)):
                return true
            case (_?, _):
                // Allow the nextResponder to make the determination.
                return super.canPerformAction(action, withSender: sender)
                
            // Paste is supported if the pasteboard has text.
            case (.none, action) where action == #selector(paste(_:)):
                return (UIPasteboard.general.string != nil) ? true :
                    // Allow the nextResponder to make the determination.
                    super.canPerformAction(action, withSender: sender)
            case (.none, _):
                return false
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    // User chose "New" sub menu command from the File menu (New Date or Text item).
    func newAction(_ sender: UICommand) {
        if let splitViewController = view.window?.rootViewController as? UISplitViewController {
            if let navigationController = splitViewController.viewControllers.first as? UINavigationController {
                if let masterVC = navigationController.visibleViewController as? MasterViewController {
                    // Create a date or resular string, based on the propertyList selection.
                    switch sender.propertyList {
                    case nil: masterVC.insert(.date(Date()))
                    case .some: masterVC.insert(.text("Item \(masterVC.tableItems.count + 1)"))
                    }
                }
            }
        }
    }
 
    // Called to cut the currently selected table row.
    override func cut(_ sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        // Add the item to the pasteboard.
        UIPasteboard.general.string = tableItems[selectedIndexPath.row].description
        // Delete the item.
        delete(self)
    }
    
    // Called to copy the currently selected table row.
    override func copy(_ sender: Any?) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        // Add the item top the pasteboard.
        UIPasteboard.general.string = tableItems[selectedIndexPath.row].description
    }
    
    // Called to paste a new table row.
    override func paste(_ sender: Any?) {
        guard let pasteString = UIPasteboard.general.string else { return }
        
        // De-select any existing item.
        if let selectedIndexes = tableView.indexPathsForSelectedRows {
            for selectionIndex in selectedIndexes {
                tableView.deselectRow(at: selectionIndex, animated: false)
            }
        }
        // Create the item to paste.
        let objectToInsert: TableItem = {
            switch dateFormatter.date(from: pasteString) {
            case let date?: return TableItem.date(date)
            case nil: return TableItem.text(pasteString)
            }
        }()
        // Insert the item to the table at the top and then select it.
        tableItems.insert(objectToInsert, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        selectRow(at: indexPath)
    }
    
    // Called by delete key UIKeyCommand, or the Edit menu to delete a table row.
    override func delete(_ sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            var newSelectedIndexPath = IndexPath(row: selectedIndexPath.row, section: 0)

            tableItems.remove(at: selectedIndexPath.row)
            tableView.deleteRows(at: [selectedIndexPath], with: .none)
            
            if newSelectedIndexPath.row >= tableItems.count {
                newSelectedIndexPath.row -= 1
                if newSelectedIndexPath.row == -1 {
                    // The user delete the last row, no more selection made.
                    detailViewController.detailItem = nil
                }
            }

            selectRow(at: newSelectedIndexPath)
        }
    }

}

// MARK: - Key Command Actions

extension MasterViewController {
    
    // User typed up the down from the keyboard.
    @objc
    func downArrowAction(_ sender: Any) {
        if let path = tableView.indexPathForSelectedRow {
            if path.row + 1 < tableItems.count {
                let newIndexPath = IndexPath(row: path.row + 1, section: 0)
                selectRow(at: newIndexPath)
            }
        }
    }
    
    // User typed up the arrow from the keyboard.
    @objc
    func upArrowAction(_ sender: Any) {
        if let path = tableView.indexPathForSelectedRow {
            if path.row - 1 >= 0 {
                let newIndexPath = IndexPath(row: path.row - 1, section: 0)
                selectRow(at: newIndexPath)
            }
        }
    }
    
    // User clicked or tapped the '+' UIBarButtonItem in the navigation bar, insert the current date object to the list.
    @objc
    func insertNewDateObject(_ sender: Any) {
        insert(.date(Date()))
    }
    
    // Insert either a date or text object.
    private func insert(_ object: TableItem) {
        tableItems.append(object)
        let indexPath = IndexPath(row: tableItems.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        // Select the added object.
        self.tableView.becomeFirstResponder()
        selectRow(at: indexPath)
    }
    
}

// MARK: - Menu Command validation

extension MasterViewController {
    
    override func validate(_ command: UICommand) {
        Swift.debugPrint("MasterViewController: validation of: \(command.title)")
  
        // Example if you want to directly disable Select All.
        /*
        if command.action == #selector(selectAll(_:)) {
            command.state = .off
        }*/
        
        super.validate(command)
    }
}

