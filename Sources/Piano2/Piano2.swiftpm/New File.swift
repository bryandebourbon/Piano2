import SwiftUI
import AVFoundation

class PianoPlayer: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    
    enum Note: UInt8 {
        case C = 60, CSharp = 61, D = 62, DSharp = 63, E = 64, F = 65
        case FSharp = 66, G = 67, GSharp = 68, A = 69, ASharp = 70, B = 71
    }
    
    init() {
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            if let soundFontURL = Bundle.main.url(forResource: "example", withExtension: "sf2") {
                try loadPianoSoundFont(from: soundFontURL)
            } else {
                print("SoundFont file not found")
            }
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadPianoSoundFont(from url: URL) throws {
        do {
            try sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: 0x79, bankLSB: 0x00)
        } catch {
            print("Error loading sound font: \(error.localizedDescription)")
            throw error
        }
    }
    
    func play(note: Note, velocity: UInt8 = 64) {
        sampler.startNote(note.rawValue, withVelocity: velocity, onChannel: 0)
    }
    
    func stop(note: Note) {
        sampler.stopNote(note.rawValue, onChannel: 0)
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // Handle interruption began
        } else if type == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                try audioEngine.start()
            } catch {
                print("Error restarting audio engine: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            // Handle new device available
            break
        case .oldDeviceUnavailable:
            // Handle old device unavailable
            break
        default:
            break
        }
    }
}
