import SwiftUI
import AVFoundation

/// A class that uses `AVAudioEngine` and `AVAudioUnitSampler` to play piano notes.
/// 
/// `PianoPlayer` sets up the audio session, loads a SoundFont (if available),
/// and handles audio session interruptions and route changes.
public class PianoPlayer: ObservableObject {
    // Keep these properties private unless you want external access to the engine/sampler
    private var audioEngine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    
    /// The different piano notes we can play, mapped to MIDI note numbers.
    public enum Note: UInt8 {
        case C = 60, CSharp = 61, D = 62, DSharp = 63, E = 64, F = 65
        case FSharp = 66, G = 67, GSharp = 68, A = 69, ASharp = 70, B = 71
    }
    
    /// Initializes a new `PianoPlayer` and configures the audio engine.
    public init() {
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            try audioEngine.start()
            
            // Attempt to load "example.sf2" from the app or package bundle
            if let soundFontURL = Bundle.module.url(forResource: "example", withExtension: "sf2") {
                try loadPianoSoundFont(from: soundFontURL)
            } else {
                print("SoundFont file not found")
            }
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        // Register for audio session notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Loads a piano SoundFont instrument from a specified file URL.
    /// - Parameter url: The file URL of the `.sf2` SoundFont.
    private func loadPianoSoundFont(from url: URL) throws {
        do {
            // program = 0, bankMSB = 0x79 is common for a piano patch,
            // but adjust if your SoundFont requires different values.
            try sampler.loadSoundBankInstrument(at: url, program: 0, bankMSB: 0x79, bankLSB: 0x00)
        } catch {
            print("Error loading sound font: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Starts playing the given note with a specified velocity.
    /// - Parameters:
    ///   - note: The MIDI note to play, as defined in `Note`.
    ///   - velocity: The note velocity (0–127). Defaults to 64.
    public func play(note: Note, velocity: UInt8 = 64) {
        sampler.startNote(note.rawValue, withVelocity: velocity, onChannel: 0)
    }
    
    /// Stops playing the given note.
    /// - Parameter note: The MIDI note to stop.
    public func stop(note: Note) {
        sampler.stopNote(note.rawValue, onChannel: 0)
    }
    
    // MARK: - Audio Session Handling
    
    @objc private func handleInterruption(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }
        
        switch type {
        case .began:
            // Handle interruption began (e.g., a phone call)
            break
            
        case .ended:
            // Restart audio after interruption
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                try audioEngine.start()
            } catch {
                print("Error restarting audio engine: \(error.localizedDescription)")
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue)
        else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            // E.g., headphones plugged in
            break
        case .oldDeviceUnavailable:
            // E.g., headphones unplugged
            break
        default:
            break
        }
    }
}
