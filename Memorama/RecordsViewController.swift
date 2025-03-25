//
//  RecordsViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit

class RecordsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableViewRecords: UITableView!
    
    struct Record{
        let num: Int
        let name: String
        let time: Int
        let errors: Int
        let date: String
        let score: Int
    }
    
    var records: [Record] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewRecords.dataSource = self
        loadRecords()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableViewRecords.dequeueReusableCell(withIdentifier: "RecordCell", for:indexPath)as! RecordsTableViewCell
        let record = records[indexPath.row]
        
        cell.labelNum.text = "\(record.num)"
        cell.labelName.text = record.name
        cell.labelDate.text = record.date
        cell.labelTime.text = "\(record.time)s"
        cell.labelScore.text = "\(record.score)"
        cell.labelErrors.text = "\(record.errors)"
        
        return cell
    }

    @IBAction func regresar() {
        dismiss(animated: true)
    }
    
    func loadRecords() {
        let recordsData = UserDefaults.standard.array(forKey: "records") as? [[String: Any]] ?? []
        print(recordsData)
        
        // Formatear la fecha en la que se registro el record para mostrarla en la vista.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        // Convertir los datos a estructuras Record
        records = recordsData.enumerated().map { index, record in
            let name = record["name"] as? String ?? "Anónimo"
            let score = record["score"] as? Int ?? 0
            let time = record["time"] as? Int ?? 0
            let errors = record["errors"] as? Int ?? 0
            let date = record["date"] as? Date ?? Date()
            
            return Record(
                num: index + 1,
                name: name,
                time: time,
                errors: errors,
                date: dateFormatter.string(from: date),
                score: score
            )
        }
        
        tableViewRecords.reloadData()
    }
}
