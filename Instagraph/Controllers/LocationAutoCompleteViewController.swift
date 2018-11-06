//
//  LocationAutoCompleteViewController.swift
//  Instagraph
//
//  Created by 魏文洲 on 19/10/2018.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import MapKit

protocol ReturnLocationProtocol {
    func setLocation(title: String, long: Double, lat: Double)
}

class LocationAutoCompleteViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var locationSuggestionTableView: UITableView!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var chosenIndexPath = IndexPath(row: 0, section: 0)
    var delegate: ReturnLocationProtocol?
    
    var locationTitle = ""
    var locationLong: Double = 0
    var locationLat: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        locationSuggestionTableView.tableHeaderView = searchController.searchBar
        //        locationSuggestionTableView.keyboardDismissMode = .onDrag
        searchController.searchBar.placeholder = "Search for places nearby"
        locationSuggestionTableView.delegate = self
        locationSuggestionTableView.dataSource = self
        searchCompleter.delegate = self
        searchController.searchBar.delegate = self
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        self.delegate?.setLocation(title: locationTitle, long: locationLong, lat: locationLat)
        dismiss(animated: true, completion: nil)
    }
    
}

extension LocationAutoCompleteViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if indexPath.section == 0 {
            cell = locationSuggestionTableView.dequeueReusableCell(withIdentifier: "noChoiceCell", for: indexPath)
            
            cell.textLabel?.text = "Do not choose any place"
        } else if indexPath.section == 1 {
            cell = locationSuggestionTableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
            let searchResult = searchResults[indexPath.row]
            
            cell.textLabel?.text = searchResult.title
            cell.detailTextLabel?.text = searchResult.subtitle
        }
        
        if indexPath != chosenIndexPath {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.isActive = false
        chosenIndexPath = indexPath
        
        if indexPath.section == 0 {
            self.locationTitle = ""
            self.locationLong = 0
            self.locationLat = 0
        } else if indexPath.section == 1 {
            let completion = searchResults[indexPath.row]
            let searchRequest = MKLocalSearchRequest(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                if let coordinate = response?.mapItems[0].placemark.coordinate {
                    self.locationTitle = self.searchResults[indexPath.row].title
                    self.locationLong = coordinate.longitude
                    self.locationLat = coordinate.latitude
                }
            }
        }
        tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.isActive = false
    }
}

extension LocationAutoCompleteViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
    }
}

extension LocationAutoCompleteViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        locationSuggestionTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
    }
}
