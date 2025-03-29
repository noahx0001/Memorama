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
        // Cargar todos los registros guardados
        let recordsData = UserDefaults.standard.array(forKey: "records") as? [[String: Any]] ?? []
        
        // Si no hay registros, crear 5 de ejemplo
        var recordsToShow: [[String: Any]] = recordsData
        
        if recordsToShow.isEmpty {
            let currentDate = Date()
            recordsToShow = [
                ["name": "Jugador 1", "score": 100, "time": 45, "errors": 2, "date": currentDate],
                ["name": "Jugador 2", "score": 90, "time": 50, "errors": 3, "date": currentDate],
                ["name": "Jugador 3", "score": 80, "time": 55, "errors": 4, "date": currentDate],
                ["name": "Jugador 4", "score": 70, "time": 60, "errors": 5, "date": currentDate],
                ["name": "Jugador 5", "score": 60, "time": 65, "errors": 6, "date": currentDate]
            ]
        }
        
        // Ordenar por score (de mayor a menor) y tomar solo los primeros 5
        let sortedRecords = recordsToShow.sorted {
            ($0["score"] as? Int ?? 0) > ($1["score"] as? Int ?? 0)
        }
        let top5Records = Array(sortedRecords.prefix(5))
        
        // Formatear y asignar a la variable records
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        records = top5Records.enumerated().map { index, record in
            Record(
                num: index + 1,
                name: record["name"] as? String ?? "Anónimo",
                time: record["time"] as? Int ?? 0,
                errors: record["errors"] as? Int ?? 0,
                date: dateFormatter.string(from: record["date"] as? Date ?? Date()),
                score: record["score"] as? Int ?? 0
            )
        }
        
        tableViewRecords.reloadData()
    }
}
