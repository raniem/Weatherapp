//
//  ThirdViewController.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import UIKit

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data = ["Use GPS", "Tampere", "London"]
    
    var alert : UIAlertController? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "ID")
        cell.textLabel?.text = self.data[indexPath.row]
        
        if (indexPath.row == 0) {
            cell.setSelected(true, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(movedObject, at: destinationIndexPath.row)
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
        FetchValue.fv.value = data[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (proposedDestinationIndexPath.row == 0) {
            return sourceIndexPath
        }
        return proposedDestinationIndexPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        
        alert = UIAlertController(title: "Add location", message: "", preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert?.addTextField(configurationHandler: { textField in
            textField.placeholder = "Insert location name"
        })
    }
    
    @IBAction func editTableView(_ sender: Any) {
        tableView.isEditing ? tableView.setEditing(false, animated: true) :
                              tableView.setEditing(true, animated: true)
    }
    
    @IBAction func addLocation(_ sender: Any) {
        if ((alert?.actions.count)! < 2) {
            alert?.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                if (!self.data.contains((self.alert?.textFields?.first?.text)!)) {
                    self.data.append((self.alert?.textFields?.first?.text)!)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(item: self.data.count - 1, section: 0)], with: .automatic)
                    self.tableView.endUpdates()
                }
                
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
