import AVFoundation
import Foundation

final class SpeechReader: NSObject, ObservableObject {
    @Published private(set) var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.allowBluetooth, .duckOthers])
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        try? AVAudioSession.sharedInstance().setActive(true)
        synthesizer.speak(utterance)
    }

    func pause() {
        _ = synthesizer.pauseSpeaking(at: .immediate)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

extension SpeechReader: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
