//
//  PlacesTableViewController.swift
//  MemorablePlaces
//
//  Created by Ahmed T Khalil on 1/20/17.
//  Copyright © 2017 kalikans. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PlacesTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var table: UITableView!
    var placesStr = [String]()
    var placesCoor = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesStr.count
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //retrieve array of places from permanent storage
        let placesStrObj = UserDefaults.standard.object(forKey: "placesStrFinal")
        
        if let tempPlacesStr = placesStrObj as? [String]{
            placesStr = tempPlacesStr
        }
        
        //retrieve array of coordinates (that correspond with places array indices) from permanent storage
        let placesCoorObj = UserDefaults.standard.object(forKey: "placesCoorFinal")
        
        if let tempPlacesCoor = placesCoorObj as? [String]{
            placesCoor = tempPlacesCoor
        }
        
        table.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")

        cell.textLabel?.text = placesStr[indexPath.row]
        
        return cell
    }
    
    //to delete by swiping shit
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete{
            placesStr.remove(at: indexPath.row)
            placesCoor.remove(at: indexPath.row)
            
            print("Places Strings After Removing: \(placesStr)")
            print("Places Coordinates After Removing: \(placesCoor)")
            
            table.reloadData()
            
            UserDefaults.standard.set(placesStr, forKey: "placesStrFinal")
            UserDefaults.standard.set(placesCoor, forKey: "placesCoorFinal")
        }
        
    }
    
    
    //if the user selects a row in the table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMap", sender: nil)
    }
    
    //prepare data before performing segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap"{
            
            let mapVC = segue.destination as! ViewController
            
            if let selectedRow = self.table.indexPathForSelectedRow?.row {
                let placesCoorSplit = placesCoor[selectedRow].components(separatedBy: ",")
                let latRecovered = Double(placesCoorSplit[0])! as CLLocationDegrees
                let lonRecovered = Double(placesCoorSplit[1])! as CLLocationDegrees
                //send latRecovered and lonRecovered to other view controller
                mapVC.latRecovered = latRecovered
                mapVC.lonRecovered = lonRecovered
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
