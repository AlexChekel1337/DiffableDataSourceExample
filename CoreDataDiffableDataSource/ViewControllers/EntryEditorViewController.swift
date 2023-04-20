//
//  EntryEditorViewController.swift
//  CoreDataDiffableDataSource
//
//  Created by Alexander Chekel on 16.04.2023.
//

import UIKit

class EntryEditorViewController: UIViewController {
    var entry: ExampleEntry!

    override func viewDidLoad() {
        super.viewDidLoad()

        (view.subviews.first as? UITextField)?.text = entry.title
    }

    @IBAction
    private func deleteButtonTap() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }

        delegate.persistentContainer.viewContext.delete(entry)
        delegate.saveContext()

        navigationController?.popViewController(animated: true)
    }
}

extension EntryEditorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        entry.title = textField.text
        entry.dateAdded = Date()

        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()

        navigationController?.popViewController(animated: true)

        return true
    }
}
