//
//  RecordsViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit

class RecordsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        printRecords()
    }

    @IBAction func regresar() {
        dismiss(animated: true)
    }
    
    func printRecords() {
        let records = UserDefaults.standard.array(forKey: "records") as? [[String: Any]] ?? []
        
        if records.isEmpty {
            print("No hay records guardados.")
        } else {
            print("🏆 Records Guardados 🏆")
            for (index, record) in records.enumerated() {
                let name = record["name"] as? String ?? "Anónimo"
                let score = record["score"] as? Int ?? 0
                let time = record["time"] as? Int ?? 0
                let errors = record["errors"] as? Int ?? 0
                let date = record["date"] as? Date ?? Date()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
                let dateString = dateFormatter.string(from: date)
                
                print("""
                \(index + 1). \(name)
                ▸ Puntos: \(score)
                ▸ Tiempo: \(time)s
                ▸ Errores: \(errors)
                ▸ Fecha: \(dateString)
                ----------------------
                """)
            }
        }
    }
}
