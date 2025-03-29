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
    // Reproductores de audio
    var backgroundMusicPlayer: AVAudioPlayer?
    var soundEffectPlayers = [AVAudioPlayer]()
    
    // Estado inicial de las cartas (volteadas)
    var isFlipped = false
    
    let baseScore = 10000
    let penaltyforError = 50
    let penaltyforTime = 10
    var finalScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupGame() // Configuración inicial del juego.
        startTimer() // Inicia el temporizador.
        verifySoundFiles()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configurando sesión de audio: \(error)")
        }
        
        
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
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configurando sesión de audio: \(error.localizedDescription)")
        }
    }
    
    @IBAction func regresar() {
        stopAllSounds()
        dismiss(animated: true)
    }
    
    func verifySoundFiles() {
        let requiredSounds = ["song-mario-bros", "coin", "win"]
        for sound in requiredSounds {
            if Bundle.main.path(forResource: sound, ofType: "mp3") == nil {
                print("⚠️ Advertencia: Archivo \(sound).mp3 no encontrado")
            }
        }
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
        playBackgroundMusic(named: "song-mario-bros")
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
            playSoundEffect(named: "coin")
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
        playSoundEffect(named: "win")
        
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
            showBasicAlert(title: "¡Ganaste!", message: "Puntaje: \(String(describing: finalScore))\nTiempo: \(timeElapsed)s\nErrores: \(errors)")
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
    // Reproducir música de fondo
    func playBackgroundMusic(named soundName: String) {
        // Detener música anterior si existe
        backgroundMusicPlayer?.stop()
        
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Error: Archivo \(soundName).mp3 no encontrado")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.numberOfLoops = -1 // Repetir indefinidamente
            player.volume = 0.7 // Volumen moderado
            player.prepareToPlay()
            player.play()
            backgroundMusicPlayer = player
        } catch {
            print("Error al reproducir música de fondo: \(error.localizedDescription)")
        }
    }
    
    func playSoundEffect(named soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            print("Error: Archivo \(soundName).mp3 no encontrado")
            return
        }
        
        do {
            // Limpiar reproductores de efectos completados
            soundEffectPlayers = soundEffectPlayers.filter { $0.isPlaying }
            
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.volume = 1.0 // Volumen completo para efectos
            player.delegate = self
            player.prepareToPlay()
            player.play()
            soundEffectPlayers.append(player)
        } catch {
            print("Error al reproducir efecto de sonido: \(error.localizedDescription)")
        }
    }
    
    // Detener todos los sonidos
    func stopAllSounds() {
        backgroundMusicPlayer?.stop()
        soundEffectPlayers.forEach { $0.stop() }
        soundEffectPlayers.removeAll()
    }
    
    func updateScore(){
        let currentScore = baseScore - (errors * penaltyforError) - (timeElapsed * penaltyforTime)
        let displayedScore = max(currentScore, 0)
        self.scoreLabel.text = "Puntos: \(displayedScore)"
    }
}

// Extensión para manejar la finalización de efectos de sonido
extension JuegoViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        soundEffectPlayers.removeAll { $0 == player }
    }
}
