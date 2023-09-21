import SwiftUI

struct ContentView: View {
    @ObservedObject var timerManager = TimerManager()
    @StateObject var settingsModel = Settings() // Use StateObject para propriedades de View
    
    @State private var text = "Start"
    @State private var selectedButton: String = "Pomodoro"
    @State private var pomodoroCount = ""
    @State private var shortBreakCount = ""

    init() {
        requestNotificationPermission()
        pomodoroCount = timerManager.formatTime()
        shortBreakCount = timerManager.formatTimeShortBreaker()
       
        
    }

    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack {
                Button(action: {
                    settingsModel.showSettings = true
                }, label: {
                    Text("Settings")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                })
                .sheet(isPresented: $settingsModel.showSettings, content: {
                    SettingsView(settingsModel: settingsModel, timerManager: timerManager)
                    // Passe as referências para SettingsView
                })
                
                Spacer()
            }
            
            VStack(alignment: .center, spacing: 20) {
                HStack(spacing: 25) {
                    Button(action: {
                        selectedButton = "Pomodoro"
                        if(!timerManager.timerStarted)
                        {
                            timerManager.Reset()
                        }
                            
                    }) {
                        Text("Pomodoro")
                            .font(Font.title3)
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundColor(.white)
                            .padding(10)
                            .background(selectedButton == "Pomodoro" ? Color("SecondColor") : Color.clear)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        selectedButton = "Short Break"
                        shortBreakCount = timerManager.formatTimeShortBreaker()
                        
                       
                    }) {
                        Text("Short Break")
                            .font(Font.title3)
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundColor(.white)
                            .padding(10)
                            .background(selectedButton == "Short Break" ? Color("SecondColor") : Color.clear)
                            .cornerRadius(10)
                    }
                }
                .padding()

                ZStack {
                    VStack(alignment: .center, spacing: 5) {
                        Text(selectedButton == "Pomodoro" ? pomodoroCount : shortBreakCount)
                            .foregroundColor(.white)
                            .font(.system(size: 80))
                            .padding(.all, 40.0)
                    }
                }
                .background(Color("SecondColor"))
                .cornerRadius(15)

                Spacer().frame(height: 5)

                Button(action: {
                    if selectedButton == "Short Break" && !timerManager.timerStarted{
                        
                        timerManager.StartShortBreaker()
                        //print(" caiu aq 1")
                    }
                    else if !timerManager.timerStarted && selectedButton == "Pomodoro"
                    {
                      
                        //print(" caiu aq 2")
                        timerManager.startTimer()
                    }
                    else
                    {
                        //print(" caiu aq 3")
                        timerManager.pauseTimer()
                    }
                  
                }) {
                    Text(text)
                        .font(Font.title3)
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(.red)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(100)
                }
                .onChange(of: timerManager.timerStarted) { newValue in
                    text = newValue ? "Pause" : "Start"
                }

                Spacer().frame(height: 5)

                VStack(spacing: 5) {
                    Text("# \(timerManager.timeToFocusCount)")
                        .font(.system(size: 15))
                        .foregroundColor(.white)

                    Text("Time to focus!")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .onReceive(timerManager.$counter) { newCounter in
            if selectedButton == "Pomodoro" {
                pomodoroCount = timerManager.formatTime()
                if newCounter == 0 {
                     selectedButton = "Short Break"
                        shortBreakCount = timerManager.formatTimeShortBreaker()
                 }
            }
        }
        .onReceive(timerManager.$Breakcounter) { newBreakCounter in
            if selectedButton == "Short Break" {
                shortBreakCount = timerManager.formatTimeShortBreaker()
                if newBreakCounter == 0 {
                     selectedButton = "Pomodoro"
                    pomodoroCount = timerManager.formatTime()
                 }
                
            }
        }

    }
}

import UserNotifications

func requestNotificationPermission() {
    let center = UNUserNotificationCenter.current()
    
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        if granted {
            // Permissão concedida pelo usuário.
            print("Permissão para notificações concedida.")
        } else if let error = error {
            // Ocorreu um erro ao solicitar permissão.
            print("Erro ao solicitar permissão para notificações: \(error.localizedDescription)")
        } else {
            // Permissão negada pelo usuário.
            print("Permissão para notificações negada.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
