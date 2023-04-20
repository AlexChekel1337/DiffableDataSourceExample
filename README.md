# DiffableDataSourceExample
This is an example project built for demonstration purposes. It uses Core Data and Diffable Data Source to reproduce an issue, when `NSDiffableDataSourceSnapshot` does not properly pick up the changes in updated items. Here's a quick demo video:

<video src="https://user-images.githubusercontent.com/26207942/233361562-ffe49599-d841-4ee3-8ad9-1b6748932a76.mov" width="500px"></video>

There's a `NSFetchedResultsController` instance which is responsible for observing items specified in fetch request, and whose delegate method `controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)` is used to notify view controller of changes in the database. As you can see in the video, insertions and deletions are animated exactly as they should be, but updates aren't. Item title or date subtitle are only updated when cell is being resued or, as shown in the video, when dismissing the view controller and presenting it again.
