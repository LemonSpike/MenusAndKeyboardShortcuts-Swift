/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Menu construction extensions for this sample.
*/

import UIKit

class MenuController {
    
    // Property list keys to access UICommand/UIKeyCommand values.
    struct CommandPListKeys {
        static let ArrowsKeyIdentifier = "id" // Arrow command-keys
        static let CitiesKeyIdentifier = "city" // City command-keys
        static let TownsIdentifierKey = "town" // Town commands
        static let StylesIdentifierKey = "font" // Font style commands
        static let ToolsIdentifierKey = "tool" // Tool commands
    }

    enum ToolType: Int {
        case lasso = 0
        case pencil = 1
        case scissors = 2
        case rotate = 3
    }

    // MARK: - Menu Titles

    enum Cities: String, CaseIterable {
        case cupertino
        case sanFrancisco
        case sanJose
        case paris
        case rome
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }

    enum Towns: String, CaseIterable {
        case bigOakFlat
        case groveland
        case sonora
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }

    enum Tools: String, CaseIterable {
        case lasso
        case pencil
        case scissors
        case rotate
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }

    enum FontStyle: String, CaseIterable {
        case plain
        case bold
        case italic
        case underline
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }

    enum Arrows: String, CaseIterable {
        case rightArrow
        case leftArrow
        case upArrow
        case downArrow
        func localizedString() -> String {
            return NSLocalizedString("\(self.rawValue)", comment: "")
        }
    }
    
    init(with builder: UIMenuBuilder) {
        // First remove the menus in the menu bar you don't want, in our case the Format menu.
        builder.remove(menu: .format)
        
        // Create and add "Open" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.openMenu(), atStartOfMenu: .file)
    
        // Create and add "New" menu command at the beginning of the File menu.
        builder.insertChild(MenuController.newMenu(), atStartOfMenu: .file)
        
        // Add the rest of the menus to the menu bar.

        // Add the Cities menu.
        builder.insertSibling(MenuController.citiesMenu(), beforeMenu: .window)
        
        // Add the Navigation menu.
        builder.insertSibling(MenuController.navigationMenu(), beforeMenu: .window)
        
        // Add the Style menu.
        builder.insertSibling(MenuController.fontStyleMenu(), beforeMenu: .window)
        
        // Add the Tools menu.
        builder.insertSibling(MenuController.toolsMenu(), beforeMenu: .window)
    }
        
    class func openMenu() -> UIMenu {
        let openCommand =
            UIKeyCommand(title: NSLocalizedString("OpenTitle", comment: ""),
                         image: nil,
                         action: #selector(AppDelegate.openAction),
                         input: "O",
                         modifierFlags: .command,
                         propertyList: nil)
        let openMenu =
            UIMenu(title: "",
                   image: nil,
                   identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.openMenu"),
                   options: .displayInline,
                   children: [openCommand])
        return openMenu
    }
    
    class func newMenu() -> UIMenu {
        // Create New Date menu key command.
        let newCommand =
            UIKeyCommand(title: NSLocalizedString("DateItemTitle", comment: ""),
                         image: nil,
                         action: #selector(MasterViewController.newAction(_:)),
                         input: "N",
                         modifierFlags: .command,
                         propertyList: nil)
        newCommand.discoverabilityTitle = NSLocalizedString("Command_N_DiscoveryTitle", comment: "")

        // Create the New Text menu command.
        let newTextCommand =
            UIKeyCommand(title: NSLocalizedString("TextItemTitle", comment: ""),
                         image: nil,
                         action: #selector(MasterViewController.newAction(_:)),
                         input: "N",
                         modifierFlags: [.command, .shift],
                         propertyList: ["Action": "NewText"])
        newCommand.discoverabilityTitle = NSLocalizedString("Command_N_DiscoveryTitle", comment: "")
        
        // Return the "New" hierarchical menu.
        return UIMenu(title: NSLocalizedString("NewCommandTitle", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.newMenu"),
                      options: .destructive,
                      children: [newCommand, newTextCommand])
    }
    
    class func citiesMenu() -> UIMenu {
        // Create the Cities menu group.
        let cities = Cities.allCases
        let cityChildrenCommands = zip(cities, 0...).map { (city, index) in
            UIKeyCommand(title: city.localizedString(),
                         image: nil,
                         action: #selector(AppDelegate.citiesMenuAction(_:)),
                         input: String(index),
                         modifierFlags: .command,
                         propertyList: [CommandPListKeys.CitiesKeyIdentifier: city.rawValue])
        }
        let citiesMenuGroup = UIMenu(title: "",
                                     image: nil,
                                     identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.citiesSubMenu"),
                                     options: .displayInline,
                                     children: cityChildrenCommands)
        
        // Create the Towns menu group.
        let towns = Towns.allCases
        let childrenCommands = towns.map { town in
            UICommand(title: town.localizedString(),
                      image: nil,
                      action: #selector(AppDelegate.townsMenuAction(_:)),
                      propertyList: [CommandPListKeys.TownsIdentifierKey: town.rawValue])
        }
        let townsMenuGroup = UIMenu(title: "",
                                    image: nil,
                                    identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.townsSubMenu"),
                                    options: .displayInline,
                                    children: childrenCommands)
        
        return UIMenu(title: NSLocalizedString("CitiesTitle", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.citiesMenu"),
                      options: [],
                      children: [citiesMenuGroup, townsMenuGroup])
    }
 
    class func navigationMenu() -> UIMenu {
        let keyCommands = [ UIKeyCommand.inputRightArrow,
                            UIKeyCommand.inputLeftArrow,
                            UIKeyCommand.inputUpArrow,
                            UIKeyCommand.inputDownArrow ]
        let arrows = Arrows.allCases
        
        let arrowKeyChildrenCommands = zip(keyCommands, arrows).map { (command, arrow) in
            UIKeyCommand(title: arrow.localizedString(),
                         image: nil,
                         action: #selector(AppDelegate.navigationMenuAction(_:)),
                         input: command,
                         modifierFlags: .command,
                         propertyList: [CommandPListKeys.ArrowsKeyIdentifier: arrow.rawValue])
        }
        
        let arrowKeysGroup = UIMenu(title: "",
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.arrowKeysSubMenu"),
                      options: .displayInline,
                      children: arrowKeyChildrenCommands)
        
        return UIMenu(title: NSLocalizedString("NavigationTitle", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.navigationMenu"),
                      options: [],
                      children: [arrowKeysGroup])
    }
    
    class func fontStyleMenu() -> UIMenu {
        let styleChildrenCommands = FontStyle.allCases.map { style in
            UICommand(title: style.localizedString(),
                      image: nil,
                      action: #selector(AppDelegate.fontStyleAction(_:)),
                      propertyList: [CommandPListKeys.StylesIdentifierKey: style.rawValue],
                      alternates: [])
        }
        
        return UIMenu(title: NSLocalizedString("StyleTitle", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.fontStylesMenu"),
                      options: [],
                      children: styleChildrenCommands)
    }
    
    class func toolsMenu() -> UIMenu {
        let lassoCommand = UICommand(title: Tools.lasso.localizedString(),
                                     image: nil,
                                     action: #selector(AppDelegate.toolsMenuAction(_:)),
                                     propertyList: [CommandPListKeys.ToolsIdentifierKey: ToolType.lasso.rawValue])
        
        let scissorsCommand = UICommand(title: Tools.scissors.localizedString(),
                                        image: nil,
                                        action: #selector(AppDelegate.toolsMenuAction(_:)),
                                        propertyList: [CommandPListKeys.ToolsIdentifierKey: ToolType.scissors.rawValue])
        
        let rotateCommand = UICommand(title: Tools.rotate.localizedString(),
                                      image: nil,
                                      action: #selector(AppDelegate.toolsMenuAction(_:)),
                                      propertyList: [CommandPListKeys.ToolsIdentifierKey: ToolType.rotate.rawValue])
        
        let pencilCommand = UICommand(title: Tools.pencil.localizedString(),
                                      image: nil,
                                      action: #selector(AppDelegate.toolsMenuAction(_:)),
                                      propertyList: [CommandPListKeys.ToolsIdentifierKey: ToolType.pencil.rawValue])

        return UIMenu(title: NSLocalizedString("ToolsTitle", comment: ""),
                      image: nil,
                      identifier: UIMenu.Identifier("com.example.apple-samplecode.menus.toolsMenu"),
                      options: [],
                      children: [lassoCommand, scissorsCommand, rotateCommand, pencilCommand])
    }
    
}

