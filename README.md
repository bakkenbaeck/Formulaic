# Formulaic

[![Version](https://img.shields.io/cocoapods/v/Formulaic.svg?style=flat)](https://cocoapods.org/pods/Formulaic)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/bakkenbaeck/Formulaic)
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)
[![License](https://img.shields.io/cocoapods/l/Formulaic.svg?style=flat)](https://cocoapods.org/pods/DATAStack)

## Usage

We recommend using a view controller with a collection view or table view (we’re not very fond of either `UICollectionViewController` or `UITableViewController`, check out [SweetUIKit](http://github.com/bakkenbaeck/SweetUIKit) for our version of those classes).

Your view controller should have a `FormDataSource` instance, with an array of `FormItem`s defining each field. Those can be a label, a text field or a button for now. We might expand it at some point to support more types and maybe combine them.

```swift
import Formulaic

class FormViewController: UIViewController {
    lazy var dataSource: FormDataSource = {
        let dataSource = FormDataSource(delegate: self)
        
        dataSource.items = [
            FormItem(title: "Title", type: .label),
            FormItem(title: "my title", fieldName: "username", type: .input, textInputValidator : nil),

            FormItem(title: "Password", type: .label),
            FormItem(title: "********", fieldName: "password", isSecureTextEntry: true, type: .input, textInputValidator: passwordValidator),

            FormItem(title: "Change Title", action: #selector(didPressButton), target: self, type: .button)
        ]

        return dataSource
    }()
    
    // […]
}

extension FormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormCell.reuseIdentifier, for: indexPath) as? FormCell else { fatalError() }
        let formItem = self.dataSource.item(at: indexPath)

        cell.formItem = formItem

        return cell
    }
}
```


Implement the `FormDataSourceDelegate` protocol to update your UI with changes coming from the code instead of from the user. A good use case is when you integrate `1Password` into your Sign In form and want to display the selected data back to the user in a simple and clean way.

```swift
extension FormViewController: FormDataSourceDelegate {
    func formDataSourceWillChangeContent() {
        self.tableView.beginUpdates()
    }

    func formDataSourceDidChangeContent(item: FormItem, at indexPath: IndexPath, for type: TableViewDataSourceDelegateChangeType) {
        if type == .update {
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    func formDataSourceDidChangeContent() {
        self.tableView.endUpdates()
    }
}
```

This is all made possible by how we implement the `FormCell` class. By calling `formItem.updateValue(to:userInitiated:)` when the user changes a value, we update our backend model. If `userInitiated` is false, we will call the `FormDataSourceDelegate` so you can update the UI accordingly.

```swift
import Formulaic

class FormCell: UITableViewCell {
    var formItem: FormItem? {
        didSet {
            guard let formItem = self.formItem else { return }

            switch formItem.type {
            case .input:
                self.textField.placeholder = formItem.title
                self.textField.text = formItem.value as? String
                self.textField.isSecureTextEntry = formItem.isSecureTextEntry

                self.label.isHidden = true
                self.button.isHidden = true
            case .label:
                self.label.text = formItem.title

                self.textField.isHidden = true
                self.button.isHidden = true
            case .button:
                if let target = formItem.target, let action = formItem.action {
                    self.button.addTarget(target, action: action, for: .touchUpInside)
                }
                self.button.setTitle(formItem.title, for: .normal)

                self.textField.isHidden = true
                self.label.isHidden = true
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none

        self.contentView.addSubview(self.label)
        self.contentView.addSubview(self.textField)
        self.contentView.addSubview(self.button)

        let horizontalMargin = CGFloat(24)
        let verticalMargin = CGFloat(8)
        let insets = UIEdgeInsets(top: verticalMargin, left: horizontalMargin, bottom: verticalMargin, right: horizontalMargin)

        self.label.fillSuperview(with: insets)
        self.textField.fillSuperview(with: insets)
        self.button.fillSuperview(with: insets)

        NotificationCenter.default.addObserver(self, selector: #selector(FormCell.textFieldDidChange), name: .UITextFieldTextDidChange, object: self.textField)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

// This is the relevant part, to ensure our model is updated
// when the user types a new value. 
extension FormCell: UITextFieldDelegate {
    func textFieldDidChange() {
        self.formItem?.updateValue(to: self.textField.text, userInitiated: true)
    }
}

```

Take a look at the `Demo` for a complete example of all of this in place.

## Installation

**Formulaic** is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github "bakkenbaeck/Formulaic"
```

## License

**Formulaic** is available under the MIT license. See the LICENSE file for more info.

## Author

Bakken & Bæck, [@bakkenbaeck](https://twitter.com/bakkenbaeck)
