import UIKit

fileprivate let FormItemDidChangeNotification = Notification.Name(rawValue: "FormItemDidChangeNotification")

let itemAnyLength = -1

enum TableViewDataSourceDelegateChangeType {
    case insert
    case delete
    case update
}

protocol TableViewDataSourceDelegate: class {
    func dataSourceWillChangeContent()
    func dataSourceDidChangeContent(item: TableItem, at indexPath: IndexPath, for type: TableViewDataSourceDelegateChangeType)
    func dataSourceDidChangeContent()
}

protocol FormItemCellDelegate: class {
    func cellDidChange(_ cell: UITableViewCell)
}

enum LoginCellDataSourceType {
    case input
    case label
    case button
}

struct TextInputValidator {
    var minLength: Int

    var maxLength: Int

    var validationRegex: NSRegularExpression?

    var validationPattern: String? {
        didSet {
            guard let pattern = self.validationPattern else {
                self.validationRegex = nil

                return
            }

            do {
                self.validationRegex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .caseInsensitive, .dotMatchesLineSeparators, .useUnicodeWordBoundaries])
            } catch {
                fatalError("Invalid regular expression pattern: \(pattern)")
            }
        }
    }

    init(minLength: Int = itemAnyLength, maxLength: Int = itemAnyLength, validationPattern: String? = nil) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.validationPattern = validationPattern
    }
}

class FormItem: TableItem {

    var title = ""

    var value: AnyHashable? {
        didSet {
            NotificationCenter.default.post(name: FormItemDidChangeNotification, object: self)
        }
    }

    var isSecureTextEntry: Bool

    var type: LoginCellDataSourceType

    var itemValidation: TextInputValidator?

    var fieldName: String?

    init(title: String, fieldName: String? = nil, isSecureTextEntry: Bool = false, type: LoginCellDataSourceType, textInputValidator: TextInputValidator? = nil) {
        self.itemValidation = textInputValidator
        self.type = type
        self.title = title
        self.fieldName = fieldName
        self.isSecureTextEntry = isSecureTextEntry

        super.init()
    }

    override var hashValue: Int {
        return self.title.hashValue
    }
}

class FormDataSource: NSObject {
    weak var delegate: TableViewDataSourceDelegate?

    var items: [FormItem]
    
    var count: Int {
        return self.items.count
    }

    init(delegate: TableViewDataSourceDelegate? = nil) {
        self.delegate = delegate
        self.items = []

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(FormDataSource.didUpdateItem(_:)), name: FormItemDidChangeNotification, object: nil)
    }

    func didUpdateItem(_ notification: Notification?) {
        guard let formItem = notification?.object as? FormItem else { return }
        guard let index = self.items.index(of: formItem) else { fatalError("FormItem doesn't belong to data source") }
        let indexPath = IndexPath(row: index, section: 0)

        self.delegate?.dataSourceWillChangeContent()
        self.delegate?.dataSourceDidChangeContent(item: formItem, at: indexPath, for: .update)
        self.delegate?.dataSourceDidChangeContent()
    }

    func item(at indexPath: IndexPath) -> FormItem {
        return self.items[indexPath.row]
    }

    func item(withFieldName fieldName: String) -> FormItem? {
        for item in self.items {
            if item.fieldName == fieldName {
                return item
            }
        }

        return nil
    }
}
