import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsModel: Settings
    @ObservedObject var timerManager: TimerManager
    
    @State private var timerCount = 12
    @State private var timerBreakCount = 12
    @State private var timeaux = 0
    let defaults = UserDefaults.standard
    @State private var editedValue = false
    @State var soundValue : Double = 10

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center) {
                Group
                {
                    Image(systemName: "clock")
                    Text("TIMER")
                }
                    .foregroundColor(.gray)
                   
                
                Spacer()
               
                    Button("Salvar") {
                        if editedValue {
                           timerManager.counter = timerCount
                            timerManager.Breakcounter = timerBreakCount
                            if(!timerManager.timerStarted)
                            {
                                UserDefaults.standard.set(timerCount, forKey: "timerCount")
                                
                                UserDefaults.standard.set(timerBreakCount, forKey: "shortBreakCount")
                            }
                         
                            editedValue = false
                        }
                    }
            }
            
            .padding(.top, -40)
        
            
            Text("Timer (minutes)")
        
            Divider()
            
            Stepper("Pomodoro: \(timerCount/60)", value: $timerCount, in: 60...3600, step: 60)
                .onChange(of: timerCount) { newValue in
                    editedValue = true
                }
           
            Divider()

            Stepper("Short Break: \(timerBreakCount/60)", value: $timerBreakCount, in: 60...3600, step: 60)
                .onChange(of: timerBreakCount) { newValue in
                    editedValue = true
                }
          
            
            HStack(alignment: .center) {
                Group
                {
                    Image(systemName: "volume.3.fill")
                    Text("SOUND")
                }
                    .foregroundColor(.gray)
                   
                
               
            }
            .padding(.top, 40)
         
            Slider(value: $soundValue, in: 0...100)

        }
        .padding(.top, -300)
        .padding()
        
        .onAppear {
            timerBreakCount = timerManager.Breakcounter
            timerCount = timerManager.counter
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsModel = Settings() // Crie uma instância de Settings
        let timerManager = TimerManager() // Crie uma instância de TimerManager
        return SettingsView(settingsModel: settingsModel, timerManager: timerManager)
    }
}


