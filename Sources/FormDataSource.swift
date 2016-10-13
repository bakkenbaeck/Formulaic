import UIKit

let FormItemDidChangeNotification = Notification.Name(rawValue: "FormItemDidChangeNotification")

public let itemAnyLength = -1

public enum FormDataSourceDelegateChangeType {
    case insert
    case delete
    case update
}

public protocol FormDataSourceDelegate: class {
    func formDataSourceWillChangeContent()
    func formDataSourceDidChangeContent(item: FormItem, at indexPath: IndexPath, for type: FormDataSourceDelegateChangeType)
    func formDataSourceDidChangeContent()
}

public protocol FormItemCellDelegate: class {
    func cellDidChange(_ cell: UITableViewCell)
}

public enum FormItemType {
    case input
    case label
    case button
}

public struct TextInputValidator {
    public var minLength: Int

    public var maxLength: Int

    public var validationPattern: String?

    public var validationRegex: NSRegularExpression?

    public init(minLength: Int = itemAnyLength, maxLength: Int = itemAnyLength, validationPattern: String? = nil) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.validationPattern = validationPattern

        if validationPattern != nil {
            guard let pattern = self.validationPattern else {
                self.validationRegex = nil

                return
            }

            do {
                self.validationRegex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .dotMatchesLineSeparators, .useUnicodeWordBoundaries])
            } catch {
                fatalError("Invalid regular expression pattern: \(pattern)")
            }
        }
    }
}


open class FormDataSource: NSObject {
    open weak var delegate: FormDataSourceDelegate?

    open var items: [FormItem]
    
    open var count: Int {
        return self.items.count
    }

    public init(delegate: FormDataSourceDelegate? = nil) {
        self.delegate = delegate
        self.items = []

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(FormDataSource.didUpdateItem(_:)), name: FormItemDidChangeNotification, object: nil)
    }

    open func didUpdateItem(_ notification: Notification?) {
        guard let formItem = notification?.object as? FormItem else { return }
        guard let index = self.items.index(of: formItem) else { fatalError("FormItem doesn't belong to data source") }
        let indexPath = IndexPath(row: index, section: 0)

        self.delegate?.formDataSourceWillChangeContent()
        self.delegate?.formDataSourceDidChangeContent(item: formItem, at: indexPath, for: .update)
        self.delegate?.formDataSourceDidChangeContent()
    }

    open func item(at indexPath: IndexPath) -> FormItem {
        return self.items[indexPath.row]
    }

    open func item(withFieldName fieldName: String) -> FormItem? {
        for item in self.items {
            if item.fieldName == fieldName {
                return item
            }
        }

        return nil
    }
}
