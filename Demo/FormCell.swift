import UIKit
import Formulaic

class FormCell: UITableViewCell {
    lazy var textField: UITextField = {
        let view = UITextField(withAutoLayout: true)
        view.font = .systemFont(ofSize: 16.0)
        view.autocapitalizationType = .none
        view.autocorrectionType = .no

        return view
    }()

    lazy var label: UILabel = {
        let view = UILabel(withAutoLayout: true)
        view.font = .boldSystemFont(ofSize: 20.0)

        return view
    }()

    lazy var button: UIButton = {
        let view = UIButton(withAutoLayout: true)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true

        let image = UIImage(color: .red)
        view.setBackgroundImage(image, for: .normal)

        return view
    }()

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

extension FormCell: UITextFieldDelegate {
    func textFieldDidChange() {
        self.formItem?.updateValue(to: self.textField.text, userInitiated: true)
    }
}
