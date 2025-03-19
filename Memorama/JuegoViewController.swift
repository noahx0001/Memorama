//
//  JuegoViewController.swift
//  Memorama
//
//  Created by Noe  on 11/03/25.
//

import UIKit
import AVFoundation

class JuegoViewController: UIViewController {

    // Referencia a la etiqueta para mostrar el tiempo transcurrido.
    @IBOutlet weak var timeLabel: UILabel!
    // Conexión de los botones de las cartas desde el Storyboard
    @IBOutlet var cardButtons: [UIButton]!
    // Array con los nombres de las imágenes de las cartas
    var cardImages = ["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10", "card11", "card12"]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame() // Configuración inicial del juego.
        startTimer() // Inicia el temporizador.
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
        playSound(named: "song-mario-bros")
    }
    
    // Voltear carta hacia abajo
    func flipCardDown(button: UIButton) {
        // Animación de volteado (dorso de la carta)
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromRight, animations: {
            button.backgroundColor = .systemBlue
            button.setTitle("", for: .normal)  // Oculta contenido
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
    
    // Voltear carta hacia arriba (simulación)
    func flipCardUp(button: UIButton, imageName: String) {
        playSound(named: "flip") // Efecto de sonido al voltear
        // Animación de volteado (frente de la carta)
        UIView.transition(with: button, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            button.backgroundColor = .white
            button.setTitle(imageName, for: .normal) // Simulamos contenido
            button.setTitleColor(.black, for: .normal)
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
        showAlert(title: "¡Juego Terminado!",
                message: "Tiempo: \(timeElapsed)s\nErrores: \(errors)")
    }
    
    // Alertas
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    // Actualizar el tiempo.
    @objc func updateTimer() {
        timeElapsed += 1 // Incrementa el tiempo
        timeLabel.text = "Tiempo: \(timeElapsed)s" // Actualiza la UI
    }
    // Sonidos
    func playSound(named soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error al reproducir sonido")
        }
    }
}
