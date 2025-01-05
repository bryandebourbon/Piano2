import SwiftUI

struct ContentView: View {
    @StateObject private var pianoPlayer = PianoPlayer()
    
    private let notes: [PianoPlayer.Note] = [
        .C, .CSharp, .D, .DSharp, .E, .F,
        .FSharp, .G, .GSharp, .A, .ASharp, .B
    ]
    
    var body: some View {
        VStack {
            Text("Piano Player")
                .font(.largeTitle)
                .padding()
            
            VStack(spacing: 10) {
                ForEach(notes, id: \.self) { note in
                    HStack {
                        Button(action: {
                            pianoPlayer.play(note: note)
                        }) {
                            Text("Play \(note.name)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            pianoPlayer.stop(note: note)
                        }) {
                            Text("Stop \(note.name)")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

extension PianoPlayer.Note {
    var name: String {
        switch self {
        case .C: return "C"
        case .CSharp: return "C#"
        case .D: return "D"
        case .DSharp: return "D#"
        case .E: return "E"
        case .F: return "F"
        case .FSharp: return "F#"
        case .G: return "G"
        case .GSharp: return "G#"
        case .A: return "A"
        case .ASharp: return "A#"
        case .B: return "B"
        }
    }
}


