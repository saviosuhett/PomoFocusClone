import Foundation
import CoreLocation
import WidgetKit
import UserNotifications
import ActivityKit
import UIKit


class TimerManager: ObservableObject {
    var timer = Timer()
    @Published var counter: Int
    
    var updateCount = 0
    @Published var timeToFocusCount = 1
    @Published var timerStarted = false
    let stopTimeKey = "StopTime"
    @Published var timerPaused = false
    var backgroundTime: Date? // Armazena o tempo em segundo plano
    let notificationIdentifier = "TempoAcabouNotification" // Use o mesmo identificador em todas as chamadas
    var pomodoroCountisOver = false
    var isPomodoro = false
    @Published var Breakcounter : Int
    
    
    init() {
        counter = UserDefaults.standard.integer(forKey: "timerCount")
        Breakcounter = UserDefaults.standard.integer(forKey: "shortBreakCount")
        if (counter == 0 || Breakcounter == 0) {
            counter = 1500
            Breakcounter = 300
        }
        
        // Adicione observadores para entrada em segundo plano e primeiro plano
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // Função chamada ao entrar em segundo plano
    @objc func appDidEnterBackground() {
        
        // Salve o tempo atual ao entrar em segundo plano
        backgroundTime = Date()
        if timerStarted{
            sendNotification(timeInSeconds: TimeInterval(counter))
            print("o tempo para disparar a notificacao e \(counter)")
        }
        
    }
    
    // Função chamada ao retornar ao primeiro plano
    @objc func appWillEnterForeground() {
        if let backgroundTime = backgroundTime {
            let currentTime = Date()
            let elapsedTime = Int(currentTime.timeIntervalSince(backgroundTime))
            
            if elapsedTime > counter
            {
                stopTimer()
                //Reset()
                timeToFocusCount += 1
                
                print("o tempo do contador é \(counter)")
                
            }
            
            else if timerStarted
            {
                counter -= elapsedTime
            }
            
            // Você pode usar 'elapsedTime' como a diferença de tempo em segundos
            // para tomar decisões com base no tempo que passou em segundo plano.
            print("Tempo em segundo plano: \(elapsedTime) segundos")
            
            print("ispomodoro ficou \(isPomodoro)")
            
            
        }
        
        // Restaure o contador ao retornar ao primeiro plano
        if timerPaused {
            counter = UserDefaults.standard.integer(forKey: stopTimeKey)
            //timerPaused = false
            timerStarted = false
        }
    }
    
    func startTimer() {
        
        if(timerPaused)
        {
            counter = UserDefaults.standard.integer(forKey: stopTimeKey)
            timerPaused = false
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimePomodoro), userInfo: nil, repeats: true)
        
        timerStarted = true
        isPomodoro = true
        
        print("ispomodoro ficou \(isPomodoro)")
    }
    
    func StartShortBreaker()
    {
        if(pomodoroCountisOver)
        {
            
        }
        else
        {
            
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeShortBreaker), userInfo: nil, repeats: true)
        
        timerStarted = true
    }
    
    func pauseTimer()
    {
        timerPaused = true
        timerStarted = false
        stopTimer()
        UserDefaults.standard.set(counter,forKey: stopTimeKey)
    }
    
    @objc func updateTimePomodoro()
    {
        if counter > 0 {
            counter -= 1
        }
        else
        {
            timeToFocusCount += 1
            stopTimer()
            Reset()
            //sendNotification()
            pomodoroCountisOver = true
        }
    }
    
    @objc func updateTimeShortBreaker()
    {
        if Breakcounter > 0 {
            Breakcounter -= 1
        }
        else
        {
            //timeToFocusCount += 1
            stopTimer()
            Reset()
            //sendNotification()
            pomodoroCountisOver = true
        }
    }
    
    
    
    func Reset()
    {
        if(isPomodoro)
        {
            counter = UserDefaults.standard.integer(forKey: "timerCount")
            print("caiu aq ")
        }
        else
        {
            print("caiu aq 2")
            Breakcounter = 300
        }
        
        
        
    }
    
    func stopTimer() {
        timer.invalidate()
        timerStarted = false
    }
    
    func formatTime() -> String {
        let minutes = counter / 60
        let seconds = counter % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    func formatTimeShortBreaker() -> String {
        let minutes = Breakcounter / 60
        let seconds = Breakcounter % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    
    func formatTimeToMinutes() -> Int {
        let minutes = counter / 60
        return minutes
    }
    
    
    func sendNotification(timeInSeconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Tempo acabou!"
        content.body = "Seu temporizador atingiu zero."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds, repeats: false)

        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        // Cancelar qualquer notificação anterior com o mesmo identificador
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            }
        }
    }


}
