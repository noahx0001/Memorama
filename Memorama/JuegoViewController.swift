//
//  JuegoViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit
import AVFoundation

class JuegoViewController: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var counterLbl: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    // Referencia a la etiqueta para mostrar el tiempo transcurrido.
    @IBOutlet weak var timeLabel: UILabel!
    // Conexión de los botones de las cartas desde el Storyboard
    @IBOutlet var cardButtons: [UIButton]!
    // Array con los nombres de las imágenes de las cartas
    var cardImages = ["mario.png", "bowser.png", "toadd.png", "gumba.png", "luigi.png", "marihuanaamarilla.png", "noviatoadd.png", "peach.png", "travis.png", "wario.png", "yoshi.png", "yoshimaloamarilloquevuela.png"]
    // Array para almacenar las cartas que están volteadas temporalmente
    var flippedCards = [UIButton]()
    // Array para almacenar las cartas que ya han coincidido
    var matchedCards = [UIButton]()
    // Tiempo de juego
    var timer: Timer?
    // Tiempo transcurrido en segundos
    var timeElapsed = 0
    // Número de errores cometidos
    var errors = 0
    // Reproductor de audio para los efectos de sonido
    var audioPlayer: AVAudioPlayer?
    
    // Estado inicial de las cartas (volteadas)
    var isFlipped = false
    
    let baseScore = 10000
    let penaltyforError = 50
    let penaltyforTime = 10
    var finalScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame() // Configuración inicial del juego.
        startTimer() // Inicia el temporizador.
        
        for button in cardButtons {
            button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            
            UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
                button.setImage(nil, for: .normal) // Asegura que la imagen desaparezca
                if let image = UIImage(named: "backgroundcard.jpeg") {
                    // Tamaño deseado para las imágenes (puedes ajustar estos valores)
                    let targetSize = CGSize(width: 70, height: 70)
                    
                    // Crear contexto de imagen para redimensionar
                    let renderer = UIGraphicsImageRenderer(size: targetSize)
                    let resizedImage = renderer.image { _ in
                        image.draw(in: CGRect(origin: .zero, size: targetSize))
                    }
                    
                    // Asignar imagen redimensionada
                    button.setImage(resizedImage, for: .normal)
                    button.imageView?.contentMode = .scaleAspectFit // Ajustar la imagen manteniendo la relación de aspecto
                }
                button.backgroundColor = .placeholderText
            }, completion: { _ in
                button.isUserInteractionEnabled = true
                button.setNeedsDisplay() // Fuerza la actualización visual del botón
            })
            
        }
    }
    
    @IBAction func regresar() {
        audioPlayer?.stop() // Detiene la reproducción
        audioPlayer = nil   // Libera los recursos del reproductor
        dismiss(animated: true) // Regresar a la pantalla anterior.
    }
    
    // Temporizador
    func startTimer() {
        // Crea un temporizador que se ejecuta cada segundo
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // Configuración inicial del juego
    func setupGame() {
        // Duplicar y mezclar las cartas
        cardImages += cardImages // Duplica las imágenes para crear pares
        cardImages.shuffle() // Mezcla aleatoreamente
        
        // Configurar estado inicial de los botones
        for button in cardButtons {
            button.setTitle("", for: .normal) // Oculta el texto inicialmente
            button.backgroundColor = .systemBlue // Color "volteado"
            button.isEnabled = true // Habilita la interacción
        }
        // Inicializa el contador del tiempo.
        timeLabel.text = "Tiempo: 0s"
        playSound(named: "song-mario-bros", loop: true)
        scoreLabel.text = "Puntos: \(baseScore)"
    }
    
    // Voltear la card cuando no se encuentra el par
    func flipCardDown(button: UIButton) {
        button.isUserInteractionEnabled = false
        
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
            button.setImage(nil, for: .normal) // Asegura que la imagen desaparezca
            if let image = UIImage(named: "backgroundcard.jpeg") {
                // Tamaño deseado para las imágenes (puedes ajustar estos valores)
                let targetSize = CGSize(width: 70, height: 70)
                
                // Crear contexto de imagen para redimensionar
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let resizedImage = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: targetSize))
                }
                
                // Asignar imagen redimensionada
                button.setImage(resizedImage, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit // Ajustar la imagen manteniendo la relación de aspecto
            }
            button.backgroundColor = .placeholderText
        }, completion: { _ in
            button.isUserInteractionEnabled = true
            button.setNeedsDisplay() // Fuerza la actualización visual del botón
        })
    }


    
    @IBAction func cardTapped(_ sender: UIButton) {
        guard let cardIndex = cardButtons.firstIndex(of: sender) else { return }
        
        guard !flippedCards.contains(sender),
                      !matchedCards.contains(sender),
                      flippedCards.count < 2 else { return }
        
        flipCardUp(button: sender,imageName:cardImages[cardIndex])
                flippedCards.append(sender)
                
                if flippedCards.count == 2 {
                    checkForMatch()
                }
    }
    
    func flipCardUp(button: UIButton, imageName: String) {
        playSound(named: "flip")
        
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            button.backgroundColor = .placeholderText
            
            if let originalImage = UIImage(named: imageName) {
                // Tamaño deseado para las imágenes (puedes ajustar estos valores)
                let targetSize = CGSize(width: 70, height: 70)
                
                // Crear contexto de imagen para redimensionar
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let resizedImage = renderer.image { _ in
                    originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
                }
                
                // Asignar imagen redimensionada
                button.setImage(resizedImage, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit // Ajustar la imagen manteniendo la relación de aspecto
            }
        })
    }
    
    // Verificar coincidencia
    func checkForMatch() {
        let card1 = flippedCards[0]
        let card2 = flippedCards[1]
        
        let index1 = cardButtons.firstIndex(of: card1)!
        let index2 = cardButtons.firstIndex(of: card2)!
        
        if cardImages[index1] == cardImages[index2] {
            // Emparejamiento correcto
            matchedCards.append(contentsOf: [card1, card2])
            flippedCards.removeAll()
            // Verifica si se completó el juego
            if matchedCards.count == cardButtons.count {
                endGame()
            }
        } else {
            // Emparejamiento incorrecto
            errors += 1 // Incrementa contador de errores
            updateScore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardDown(button: card1)
                self.flipCardDown(button: card2)
                self.flippedCards.removeAll()
            }
        }
    }
    // Finalizar juego
    func endGame() {
        timer?.invalidate() // Detiene el temporizador
        playSound(named: "win") // Sonido de victoria
        
        // Calcular el puntaje final
        finalScore = baseScore - (errors * penaltyforError) - (timeElapsed * penaltyforTime)
        finalScore = max(finalScore, 0)
            
            // Verificar si es un nuevo record
            let records = UserDefaults.standard.array(forKey: "records") as? [[String: Any]] ?? []
            let sortedRecords = records.sorted { ($0["score"] as? Int ?? 0) > ($1["score"] as? Int ?? 0) }
            let isNewRecord = sortedRecords.count < 5 || finalScore > (sortedRecords.last?["score"] as? Int ?? 0)
            
            if isNewRecord {
                // Pedir nombre solo si es nuevo record
                askForNameAndSaveScore(finalScore)
            } else {
                // Mostrar alerta simple si no es record
                showBasicAlert(title: "¡Ganaste!", message: "Puntaje: \(finalScore)\nTiempo: \(timeElapsed)s\nErrores: \(errors)")
            }
    }
    
    // Alerta básica (sin campo de texto)
    func showBasicAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Alertas
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Enter your name" }
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            _ in let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? "Anonymous"
            
            self.saveScore(self.finalScore, name: name)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
       
        present(alert, animated: true)
    }
    
    func saveScore(_ score: Int, name: String) {
        var records = UserDefaults.standard.array(forKey: "records") as? [[String: Any]] ?? []
        
        // Crear nuevo record
        let newRecord = [
            "name": name,
            "score": score,
            "time": timeElapsed,
            "errors": errors,
            "date": Date()
        ] as [String : Any]
        
        // Agregar y ordenar records
        records.append(newRecord)
        records.sort { ($0["score"] as? Int ?? 0) > ($1["score"] as? Int ?? 0) }
        
        // Mantener solo los 5 mejores
        if records.count > 5 {
            records = Array(records[0..<5])
        }
        
        UserDefaults.standard.set(records, forKey: "records")
    }
    func askForNameAndSaveScore(_ score: Int) {
        let alert = UIAlertController(
                title: "¡Nuevo Record!",
                message: "Ingresa tu nombre:",
                preferredStyle: .alert
            )
            alert.addTextField { textField in
                textField.placeholder = "Tu nombre"
            }
            alert.addAction(UIAlertAction(title: "Guardar", style: .default) { _ in
                if let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty {
                    self.saveScore(score, name: name)
                }
            })
            present(alert, animated: true)
    }
    // Actualizar el tiempo.
    @objc func updateTimer() {
        timeElapsed += 1 // Incrementa el tiempo
        timeLabel.text = "Tiempo: \(timeElapsed)s" // Actualiza la UI
        updateScore()
    }
    // Sonidos
    func playSound(named soundName: String, loop: Bool = false) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = loop ? -1 : 0 // -1 para bucle, 0 para una sola vez.
            audioPlayer?.play()
        } catch {
            print("Error al reproducir sonido")
        }
    }
    
    func updateScore(){
        let currentScore = baseScore - (errors * penaltyforError) - (timeElapsed * penaltyforTime)
        let displayedScore = max(currentScore, 0)
        self.scoreLabel.text = "Puntos: \(displayedScore)"
    }
}
