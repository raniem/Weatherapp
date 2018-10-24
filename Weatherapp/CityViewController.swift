//
//  ThirdViewController.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import UIKit

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var locationList = ["Use GPS"]
    var didDeleteRow = false
    
    var alert : UIAlertController? = nil
    
    let uD = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ID")
        cell.textLabel?.text = self.locationList[indexPath.row]
        
        if (indexPath.row == 0) {
            cell.setSelected(true, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.locationList[sourceIndexPath.row]
        locationList.remove(at: sourceIndexPath.row)
        locationList.insert(movedObject, at: destinationIndexPath.row)
    }
    
    internal func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (indexPath.row == 0) {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == 0) {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FetchValue.fv.value = locationList[indexPath.row]
        uD.set(FetchValue.fv.value, forKey: "chosenLocation")
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.row == 0) {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.locationList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.uD.set(self.locationList, forKey: "locationList")
            didDeleteRow = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if (uD.value(forKey: "locationList") != nil) {
            locationList = uD.array(forKey: "locationList") as! [String]
            tableView.reloadData()
        }
        
        if (uD.value(forKey: "chosenLocation") != nil) {
            print(uD.value(forKey: "chosenLocation")!)
            tableView.selectRow(at: IndexPath(row: locationList.index(of: uD.value(forKey: "chosenLocation") as! String)!, section: 0), animated: true, scrollPosition: .top)
        } else {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        }
        
        FetchValue.fv.value = locationList[((tableView.indexPathForSelectedRow)?.row)!]
        
        alert = UIAlertController(title: "Add location", message: "", preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert?.addTextField(configurationHandler: { textField in
            textField.placeholder = "Insert location name"
        })
    }
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.isEditing ? tableView.setEditing(false, animated: true) :
                              tableView.setEditing(true, animated: true)
        
        if (!tableView.isEditing && didDeleteRow) {
            tableView.selectRow(at: IndexPath(row: (locationList.count - 1 > 0 ?  locationList.count - 1 : 0), section: 0), animated: true, scrollPosition: .top)
            FetchValue.fv.value = locationList[((tableView.indexPathForSelectedRow)?.row)!]
            didDeleteRow = false
        } else if (!tableView.isEditing) {
            tableView.selectRow(at: IndexPath(row: locationList.index(of: FetchValue.fv.value)!, section: 0), animated: true, scrollPosition: .top)
        }
    }
    
    @IBAction func addLocation(_ sender: Any) {
        if ((alert?.actions.count)! < 2) {
            alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                if (!self.locationList.contains((self.alert?.textFields?.first?.text)!)) {
                    self.locationList.append((self.alert?.textFields?.first?.text)!)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(item: self.locationList.count - 1, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
                
                self.uD.set(self.locationList, forKey: "locationList")
                
                self.alert?.textFields?.first?.text = ""
                self.alert?.textFields?.first?.placeholder = "Insert location name"
            }))
        }
        
        self.present(alert!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
