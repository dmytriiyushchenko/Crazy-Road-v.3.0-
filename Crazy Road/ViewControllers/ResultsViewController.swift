//
//  ResultsViewController.swift
//  Crazy Road
//
//  Created by Dmytrii  on 26.11.2025.
//

import UIKit

class ResultsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var results: [GameResult] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Results"
        
        setupTableView()
        loadResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadResults()
    }
    
    // MARK: - Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadResults() {
        results = ResultsManager.shared.loadResults()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        let result = results[indexPath.row]

        cell.textLabel?.text = "\(indexPath.row + 1). Time: \(result.timeString) - \(result.dateString)"
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ResultsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
