import UIKit
import SweetUIKit
import Formulaic

class ViewController: SweetTableController {

    lazy var dataSource: FormDataSource = {
        let dataSource = FormDataSource(delegate: self)

        dataSource.items = [
            FormItem(title: "Title", type: .label),
            FormItem(title: "my title", fieldName: "username", type: .input, textInputValidator : nil),

            FormItem(title: "Password", type: .label),
            FormItem(title: "********", fieldName: "password", isSecureTextEntry: true, type: .input, textInputValidator: nil),

            FormItem(title: "Change Title", action: #selector(didPressButton), target: self, type: .button)
        ]

        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        var inset = self.tableView.contentInset
        inset.top = 100
        self.tableView.contentInset = inset
        self.tableView.separatorStyle = .none

        self.tableView.dataSource = self
        self.tableView.register(FormCell.self)
    }

    func didPressButton() {
        print("Did press button")
        if let item = self.dataSource.item(withFieldName: "username") {
            item.updateValue(to: "This title was updated from the backend!", userInitiated: false)
        }
    }
}

extension ViewController: UITableViewDataSource {
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

extension ViewController: FormDataSourceDelegate {
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
