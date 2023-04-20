//
//  DiffableDataSourceViewController.swift
//  CoreDataDiffableDataSource
//
//  Created by Alexander Chekel on 16.04.2023.
//

import CoreData
import UIKit

class DiffableDataSourceViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, ExampleEntry>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ExampleEntry>

    enum Section {
        case main
    }

    @IBOutlet
    private var tableView: UITableView!

    private lazy var dataSource: DataSource = makeDataSource()
    private var fetchedResultsController: NSFetchedResultsController<ExampleEntry>?
    private var selectedEntry: ExampleEntry?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = dataSource

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let fetchRequest = ExampleEntry.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ExampleEntry.dateAdded, ascending: false)]

            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: delegate.persistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController.delegate = self

            self.fetchedResultsController = fetchedResultsController

            do {
                try fetchedResultsController.performFetch()

                if let entries = fetchedResultsController.fetchedObjects {
                    update(with: entries)
                }
            } catch {
                print(error)
            }
        }
    }

    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            var configuration = UIListContentConfiguration.subtitleCell()
            configuration.text = itemIdentifier.title
            configuration.secondaryText = "\(itemIdentifier.dateAdded ?? Date())"
            cell.contentConfiguration = configuration
            cell.accessoryType = .disclosureIndicator

            return cell
        }
    }

    private func update(with items: [ExampleEntry]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @IBAction
    private func plusButtonTap() {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let entry = ExampleEntry(context: delegate.persistentContainer.viewContext)
        entry.title = UUID().uuidString
        entry.dateAdded = Date()

        delegate.saveContext()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard
            segue.identifier == "editEntry",
            let editorViewController = segue.destination as? EntryEditorViewController,
            let selectedEntry
        else {
            return print("Failed to prepare for segue")
        }

        editorViewController.entry = selectedEntry

        self.selectedEntry = nil
    }
}

extension DiffableDataSourceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let entry = dataSource.itemIdentifier(for: indexPath) {
            selectedEntry = entry
            performSegue(withIdentifier: "editEntry", sender: self)
        }
    }
}

extension DiffableDataSourceViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let entries = fetchedResultsController?.fetchedObjects else {
            return print("No fetched objects")
        }

        update(with: entries)
    }
}
