import Foundation
import SweetSwift

open class FormItem: Hashable {

    public var title = ""

    fileprivate var _value: AnyHashable?

    public var value: AnyHashable? {
        get {
            return _value
        }
    }

    public var isSecureTextEntry: Bool

    public var type: FormItemType

    public var textInputValidator: TextInputValidator?

    public var fieldName: String?

    public var action: Selector?

    public var target: Any?

    public init(title: String, fieldName: String? = nil, action: Selector? = nil, target: Any? = nil, isSecureTextEntry: Bool = false, type: FormItemType, textInputValidator: TextInputValidator? = nil) {
        self.action = action
        self.target = target
        self.textInputValidator = textInputValidator
        self.type = type
        self.title = title
        self.fieldName = fieldName
        self.isSecureTextEntry = isSecureTextEntry
    }

    public var hashValue: Int {
        return self.title.hashValue
    }

    public static func ==(lhs: FormItem, rhs: FormItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func updateValue(to value: AnyHashable?, userInitiated: Bool) {
        self._value = value
        
        if !userInitiated {
            NotificationCenter.default.post(name: FormItemDidChangeNotification, object: self)
        }
    }

    public func validate() -> Bool {
        guard let value = self.value as? String else { return true }
        guard let validator = self.textInputValidator else { return true }

        let none = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: value.length)

        var isValid = true

        if isValid && validator.minLength != itemAnyLength {
            isValid = value.length >= validator.minLength
        }

        if isValid && validator.maxLength != itemAnyLength {
            isValid = value.length <= validator.maxLength
        }

        if isValid {
            if  let validationRegex = validator.validationRegex {
                isValid = validationRegex.numberOfMatches(in: value, options: none, range: range) >= 1
            }
        }

        return isValid
    }
}
