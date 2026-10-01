import AVFoundation
import Combine
import Foundation
import MediaPlayer

enum SpeechRate: Double, CaseIterable, Identifiable {
    case slow = 0.8
    case normal = 1.0
    case fast = 1.2
    case faster = 1.4

    var id: Double { rawValue }
    var label: String { rawValue == 1 ? "1×" : String(format: "%.1f×", rawValue) }

    var utteranceRate: Float {
        let rate = AVSpeechUtteranceDefaultSpeechRate * Float(rawValue)
        return min(max(rate, AVSpeechUtteranceMinimumSpeechRate), AVSpeechUtteranceMaximumSpeechRate)
    }
}

final class SpeechReader: NSObject, ObservableObject {
    @Published private(set) var isSpeaking = false
    @Published private(set) var isPaused = false
    @Published private(set) var currentParagraphIndex = -1
    @Published private(set) var totalParagraphs = 0
    @Published private(set) var voices: [AVSpeechSynthesisVoice] = []
    @Published private(set) var selectedVoiceIdentifier: String?
    @Published private(set) var rate: SpeechRate = .normal
    /// Identifies what is being read (guide and chapter), so the reader can tell whether the player belongs to the visible chapter.
    @Published private(set) var sourceKey: String?

    var isActive: Bool { isSpeaking || isPaused }
    var selectedVoiceName: String? { voices.first(where: { $0.identifier == selectedVoiceIdentifier })?.name }

    private let synthesizer = AVSpeechSynthesizer()
    private let defaults: UserDefaults
    private(set) var languageTag = "pt-BR"
    private var paragraphs: [String] = []
    private var currentUtterance: AVSpeechUtterance?
    private var nowPlayingTitle = ""
    private var nowPlayingSubtitle = ""
    private var remoteCommandTargets: [(MPRemoteCommand, Any)] = []

    private static let rateKey = "catecismo.voice.rate"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
        synthesizer.delegate = self
        rate = SpeechRate(rawValue: defaults.double(forKey: Self.rateKey)) ?? .normal
        refreshVoices()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        synthesizer.stopSpeaking(at: .immediate)
        unregisterRemoteCommands()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Selects voices for the language of the text being read, which is not necessarily the UI language.
    func setLanguage(_ identifier: String) {
        let language = AppLanguage.contentTag(for: Locale(identifier: identifier))
        guard language != languageTag else { return }
        stop()
        languageTag = language
        refreshVoices()
    }

    private var voicePreferenceKey: String { "catecismo.voice.\(languageTag)" }

    private func refreshVoices() {
        let prefix = String(languageTag.prefix(2)).lowercased()
        let exact = languageTag.lowercased()
        voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.lowercased().hasPrefix(prefix) }
            .sorted { lhs, rhs in
                let lhsExact = lhs.language.lowercased() == exact, rhsExact = rhs.language.lowercased() == exact
                if lhsExact != rhsExact { return lhsExact }
                if lhs.quality != rhs.quality { return lhs.quality.rawValue > rhs.quality.rawValue }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        // Earlier versions stored the voice name; resolve it once to a stable identifier.
        let stored = defaults.string(forKey: voicePreferenceKey)
            ?? (languageTag == "pt-BR" ? defaults.string(forKey: "catecismo.voice") : nil)
        selectedVoiceIdentifier = voices.first(where: { $0.identifier == stored })?.identifier
            ?? voices.first(where: { $0.name == stored })?.identifier
    }

    func speak(_ paragraphs: [String], startAt: Int = 0, sourceKey: String, title: String, subtitle: String) {
        cancelCurrentUtterance()
        self.paragraphs = paragraphs
        self.sourceKey = sourceKey
        nowPlayingTitle = title
        nowPlayingSubtitle = subtitle
        totalParagraphs = paragraphs.count
        guard !paragraphs.isEmpty else { stop(); return }
        activateSession()
        registerRemoteCommands()
        speakParagraph(at: min(max(startAt, 0), paragraphs.count - 1))
    }

    func resume() {
        guard isPaused else { return }
        activateSession()
        if synthesizer.isPaused {
            _ = synthesizer.continueSpeaking()
        } else {
            speakParagraph(at: max(currentParagraphIndex, 0))
        }
        isPaused = false
        isSpeaking = true
        updateNowPlaying()
    }

    func pause() {
        guard isSpeaking else { return }
        if !synthesizer.pauseSpeaking(at: .word) { cancelCurrentUtterance() }
        isPaused = true
        isSpeaking = false
        updateNowPlaying()
    }

    func togglePlayPause() { isSpeaking ? pause() : resume() }

    func stop() {
        cancelCurrentUtterance()
        isSpeaking = false
        isPaused = false
        currentParagraphIndex = -1
        sourceKey = nil
        unregisterRemoteCommands()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        deactivateSession()
    }

    func chooseVoice(_ voice: AVSpeechSynthesisVoice) {
        selectedVoiceIdentifier = voice.identifier
        defaults.set(voice.identifier, forKey: voicePreferenceKey)
        restartCurrentParagraphIfNeeded()
    }

    func useDefaultVoice() {
        selectedVoiceIdentifier = nil
        defaults.removeObject(forKey: voicePreferenceKey)
        if languageTag == "pt-BR" { defaults.removeObject(forKey: "catecismo.voice") }
        restartCurrentParagraphIfNeeded()
    }

    func setRate(_ newRate: SpeechRate) {
        guard newRate != rate else { return }
        rate = newRate
        defaults.set(newRate.rawValue, forKey: Self.rateKey)
        restartCurrentParagraphIfNeeded()
    }

    func next() {
        guard isActive, currentParagraphIndex + 1 < paragraphs.count else { return }
        speakParagraph(at: currentParagraphIndex + 1)
    }

    func previous() {
        guard isActive else { return }
        speakParagraph(at: max(currentParagraphIndex - 1, 0))
    }

    private func restartCurrentParagraphIfNeeded() {
        guard isActive, paragraphs.indices.contains(currentParagraphIndex) else { return }
        speakParagraph(at: currentParagraphIndex)
    }

    private func speakParagraph(at index: Int) {
        guard paragraphs.indices.contains(index) else { stop(); return }
        cancelCurrentUtterance()
        let utterance = AVSpeechUtterance(string: paragraphs[index])
        utterance.voice = voices.first(where: { $0.identifier == selectedVoiceIdentifier }) ?? AVSpeechSynthesisVoice(language: languageTag)
        utterance.rate = rate.utteranceRate
        currentUtterance = utterance
        currentParagraphIndex = index
        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
        updateNowPlaying()
    }

    /// Stops the current utterance without tearing down the session, so skipping paragraphs does not unduck other audio.
    private func cancelCurrentUtterance() {
        currentUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [])
        try? session.setActive(true)
    }

    private func deactivateSession() {
        // Deactivating while the synthesizer is still flushing audio fails; retry once it has stopped.
        if (try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)) == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self, !self.isActive else { return }
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: rawType) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch type {
            case .began:
                if self.isSpeaking { self.pause() }
            case .ended:
                let rawOptions = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
                if AVAudioSession.InterruptionOptions(rawValue: rawOptions).contains(.shouldResume), self.isPaused {
                    self.resume()
                }
            @unknown default:
                break
            }
        }
    }

    private func registerRemoteCommands() {
        guard remoteCommandTargets.isEmpty else { return }
        let center = MPRemoteCommandCenter.shared()
        func add(_ command: MPRemoteCommand, _ action: @escaping (SpeechReader) -> Void) {
            command.isEnabled = true
            let target = command.addTarget { [weak self] _ in
                guard let self else { return .commandFailed }
                action(self)
                return .success
            }
            remoteCommandTargets.append((command, target))
        }
        add(center.playCommand) { $0.resume() }
        add(center.pauseCommand) { $0.pause() }
        add(center.togglePlayPauseCommand) { $0.togglePlayPause() }
        add(center.stopCommand) { $0.stop() }
        add(center.nextTrackCommand) { $0.next() }
        add(center.previousTrackCommand) { $0.previous() }
    }

    private func unregisterRemoteCommands() {
        for (command, target) in remoteCommandTargets {
            command.removeTarget(target)
        }
        remoteCommandTargets.removeAll()
    }

    private func updateNowPlaying() {
        guard isActive else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: nowPlayingTitle,
            MPMediaItemPropertyArtist: nowPlayingSubtitle,
            MPNowPlayingInfoPropertyPlaybackRate: isSpeaking ? 1.0 : 0.0,
        ]
        if totalParagraphs > 0 {
            info[MPNowPlayingInfoPropertyPlaybackQueueCount] = totalParagraphs
            info[MPNowPlayingInfoPropertyPlaybackQueueIndex] = max(currentParagraphIndex, 0)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}

extension SpeechReader: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self, utterance === self.currentUtterance else { return }
            let nextIndex = self.currentParagraphIndex + 1
            if self.paragraphs.indices.contains(nextIndex) {
                self.speakParagraph(at: nextIndex)
            } else {
                self.stop()
            }
        }
    }
}
