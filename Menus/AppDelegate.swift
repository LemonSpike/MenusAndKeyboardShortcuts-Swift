/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main UIApplicationDelegate to this sample.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /** The registration domain is volatile.  It does not persist across launches.
            You must register your defaults at each launch; otherwise you will get (system) default values when accessing
            the values of preferences the user (via the Settings app) or your app (via set*:forKey:) has not modified.
            Registering a set of default values ensures that your app always has a known good set of values to operate on.
        */
        registerDefaultsFromSettingsBundle()
        
        return true
    }

    // MARK: - Menus
    
    var menuController: MenuController!
    
    /** Add the various menus to the menu bar.
        The system only asks UIApplication and UIApplicationDelegate for the main menus.
        Main menus appear regardless of who is in the responder chain.
    
        Note: These menus and menu commands are localized to Chinese (Simplified) in this sample.
        To change the app to run in to Chinese, refer to Xcode Help on Testing localizations:
            https://help.apple.com/xcode/mac/current/#/dev499a9529e
    */
    override func buildMenu(with builder: UIMenuBuilder) {

        // Start off with just plain font style.
        fontMenuStyleStates.insert(MenuController.FontStyle.plain.rawValue)
        
        /** First check if the builder object is using the main system menu, which is the main menu bar.
            If you want to check if the builder is for a contextual menu, check for: UIMenuSystem.context
         */
        if builder.system == .main {
            menuController = MenuController(with: builder)
        }
    }
    
    // The font style check states used in the Style menu.
    var fontMenuStyleStates = Set<String>()
    
    // You are requested to update the state of a given command from a menu; Here you adjust the Styles menu.
    // Note: Only command groups that you add will be called to validate.
    override func validate(_ command: UICommand) {
        // Obtain the plist of the incoming command.
        if let fontStyleDict = command.propertyList as? [String: String] {
            // Check if the command comes from the Styles menu.
            if let fontStyle = fontStyleDict[MenuController.CommandPListKeys.StylesIdentifierKey] {
                // Update the "Style" menu command state (checked or unchecked).
                command.state = fontMenuStyleStates.contains(fontStyle) ? .on : .off
            }
        }
    }
            
    // MARK: - Menu Actions

    @objc
    // User chose "Open" from the File menu.
    func openAction(_ sender: AnyObject) {
        Swift.debugPrint(#function)
    }
    
    @objc
    // User chose an item from the menu grouping of city titles.
    func citiesMenuAction(_ sender: AnyObject) {
        if let keyCommand = sender as? UIKeyCommand {
            if let identifier = keyCommand.propertyList as? [String: String] {
                if let value = identifier[MenuController.CommandPListKeys.CitiesKeyIdentifier] {
                    Swift.debugPrint("City command = \(String(describing: value))")
                }
            }
        }
    }
    
    @objc
    // User chose an item from the menu grouping of town titles.
    func townsMenuAction(_ sender: AnyObject) {
        if let command = sender as? UICommand {
            if let identifier = command.propertyList as? [String: String] {
                if let value = identifier[MenuController.CommandPListKeys.TownsIdentifierKey] {
                    Swift.debugPrint("Town command = \(value)")
                }
            }
        }
    }
    
    @objc
    // User chose an item from the "Navigation" menu of key commands or performed that key command.
    func navigationMenuAction(_ sender: AnyObject) {
        if let keyCommand = sender as? UIKeyCommand {
            if let identifier = keyCommand.propertyList as? [String: String] {
                if let value = identifier[MenuController.CommandPListKeys.ArrowsKeyIdentifier] {
                    Swift.debugPrint("Navigation command = \(value)")
                }
            }
        }
    }
    
    @objc
    // User chose an item from the "Font" menu.
    func fontStyleAction(_ sender: AnyObject) {
        if let keyCommand = sender as? UICommand {
            if let fontStyleDict = keyCommand.propertyList as? [String: String] {
                if let fontStyle = fontStyleDict[MenuController.CommandPListKeys.StylesIdentifierKey] {
                    if fontMenuStyleStates.contains(fontStyle) {
                        fontMenuStyleStates.remove(fontStyle)
                    } else {
                        fontMenuStyleStates.insert(fontStyle)
                    }
                }
            }
        }
    }
    
    @objc
    // User chose an item from the "Tools" menu.
    func toolsMenuAction(_ sender: AnyObject) {
        if let command = sender as? UICommand {
            if let toolDict = command.propertyList as? [String: Int] {
                if let value = toolDict[MenuController.CommandPListKeys.ToolsIdentifierKey] {
                    if let enumValue = MenuController.ToolType(rawValue: value) {
                        switch enumValue {
                        case .pencil:
                            Swift.debugPrint("Pencil selected")
                        case .lasso:
                            Swift.debugPrint("Lasso selected")
                        case .scissors:
                            Swift.debugPrint("Scissors selected")
                        case .rotate:
                            Swift.debugPrint("Rotate selected")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Preferences
    
    enum BackgroundColors: Int {
        case blue = 1
        case teal = 2
        case indigo = 3
    }
    
    // Locates the file representing the root page of the settings for this app and registers the loaded values as the app's defaults.
    func registerDefaultsFromSettingsBundle() {
        let settingsUrl =
            Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        let settingsPlist = NSDictionary(contentsOf: settingsUrl)!
        if let preferences = settingsPlist["PreferenceSpecifiers"] as? [NSDictionary] {
            var defaultsToRegister = [String: Any]()
    
            for prefItem in preferences {
                guard let key = prefItem["Key"] as? String else {
                    continue
                }
                defaultsToRegister[key] = prefItem["DefaultValue"]
            }
            UserDefaults.standard.register(defaults: defaultsToRegister)
        }
    }
    
}
