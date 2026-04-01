import AVFoundation
import Combine
import SwiftUI

// MARK: - 音楽スタイル
enum MusicStyle: String, CaseIterable, Codable {
    case ambient  = "ambient"
    case peaceful = "peaceful"
    case upbeat   = "upbeat"
    case jazz     = "jazz"
    case pop      = "pop"

    var displayName: String {
        switch self {
        case .ambient:  return "✨ アンビエント"
        case .peaceful: return "🌙 やすらぎ"
        case .upbeat:   return "⚡ アップビート"
        case .jazz:     return "🎷 ジャズ"
        case .pop:      return "🎵 ポップ"
        }
    }

    var description: String {
        switch self {
        case .ambient:  return "穏やかで落ち着いた音色"
        case .peaceful: return "ゆったりとした癒しの音楽"
        case .upbeat:   return "テンポよく元気が出る音楽"
        case .jazz:     return "おしゃれなジャズ風の音楽"
        case .pop:      return "明るくノリのいい音楽"
        }
    }

    // (周波数 Hz, 音の長さ 秒)
    var melody: [(freq: Double, dur: Double)] {
        switch self {
        case .ambient:
            return [
                (261.63, 2.2),  // C4
                (329.63, 1.8),  // E4
                (392.00, 2.0),  // G4
                (440.00, 1.6),  // A4
                (523.25, 2.6),  // C5
                (440.00, 1.8),  // A4
                (392.00, 2.0),  // G4
                (329.63, 1.6),  // E4
                (293.66, 2.0),  // D4
                (261.63, 3.2),  // C4
                (196.00, 2.4),  // G3
                (261.63, 2.0),  // C4
            ]
        case .peaceful:
            return [
                (196.00, 3.8),  // G3 — 低くゆっくり
                (220.00, 3.2),  // A3
                (261.63, 4.0),  // C4
                (220.00, 3.6),  // A3
                (196.00, 4.2),  // G3
                (174.61, 3.8),  // F3
                (196.00, 5.0),  // G3 — 長め
                (261.63, 3.2),  // C4
                (220.00, 4.0),  // A3
                (196.00, 5.5),  // G3 — 最長
            ]
        case .upbeat:
            return [
                (523.25, 0.7),  // C5
                (587.33, 0.6),  // D5
                (659.26, 0.7),  // E5
                (698.46, 0.5),  // F5
                (783.99, 0.8),  // G5
                (698.46, 0.5),  // F5
                (659.26, 0.6),  // E5
                (523.25, 0.7),  // C5
                (440.00, 0.6),  // A4
                (493.88, 0.7),  // B4
                (523.25, 1.0),  // C5
                (392.00, 0.6),  // G4
                (440.00, 0.7),  // A4
                (523.25, 1.2),  // C5
            ]
        case .jazz:
            return [
                (293.66, 1.2),  // D4
                (329.63, 0.9),  // E4
                (369.99, 1.0),  // F#4
                (392.00, 0.8),  // G4
                (440.00, 1.4),  // A4
                (466.16, 0.7),  // Bb4
                (493.88, 1.1),  // B4
                (440.00, 0.9),  // A4
                (369.99, 1.2),  // F#4
                (329.63, 0.8),  // E4
                (293.66, 1.6),  // D4
                (261.63, 0.7),  // C4
                (293.66, 1.0),  // D4
                (220.00, 2.0),  // A3 — 解決
            ]
        case .pop:
            return [
                (523.25, 0.9),  // C5
                (523.25, 0.5),  // C5
                (659.26, 1.0),  // E5
                (587.33, 0.8),  // D5
                (523.25, 0.6),  // C5
                (493.88, 1.2),  // B4
                (440.00, 0.8),  // A4
                (493.88, 0.6),  // B4
                (523.25, 1.0),  // C5
                (587.33, 0.8),  // D5
                (659.26, 1.4),  // E5
                (523.25, 0.9),  // C5
                (440.00, 1.6),  // A4
                (392.00, 2.0),  // G4 — 着地
            ]
        }
    }

    var reverbPreset: AVAudioUnitReverbPreset {
        switch self {
        case .ambient:  return .mediumHall
        case .peaceful: return .cathedral
        case .upbeat:   return .smallRoom
        case .jazz:     return .mediumRoom
        case .pop:      return .plate
        }
    }

    var reverbMix: Float {
        switch self {
        case .ambient:  return 42
        case .peaceful: return 68
        case .upbeat:   return 18
        case .jazz:     return 28
        case .pop:      return 22
        }
    }

    var volume: Float {
        switch self {
        case .ambient:  return 0.22
        case .peaceful: return 0.18
        case .upbeat:   return 0.26
        case .jazz:     return 0.24
        case .pop:      return 0.25
        }
    }

    var noteGap: ClosedRange<Double> {
        switch self {
        case .ambient:  return 0.25...0.65
        case .peaceful: return 0.40...0.90
        case .upbeat:   return 0.05...0.20
        case .jazz:     return 0.08...0.30
        case .pop:      return 0.06...0.18
        }
    }
}

// MARK: - バックグラウンドミュージックプレイヤー（AVAudioEngine で音声ファイル不要）
final class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer()

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "bgm.enabled")
            isEnabled ? startEngine() : stopEngine()
        }
    }

    @Published var currentStyle: MusicStyle {
        didSet {
            UserDefaults.standard.set(currentStyle.rawValue, forKey: "bgm.style")
            if isEnabled && isEngineRunning {
                restartWithNewStyle()
            }
        }
    }

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let reverb = AVAudioUnitReverb()
    private var isEngineRunning = false
    private var noteIndex = 0

    private let sampleRate: Double = 44100.0

    private init() {
        isEnabled = UserDefaults.standard.object(forKey: "bgm.enabled") as? Bool ?? true
        let savedStyle = UserDefaults.standard.string(forKey: "bgm.style") ?? ""
        currentStyle = MusicStyle(rawValue: savedStyle) ?? .ambient
        setupEngine()
    }

    // MARK: - セットアップ
    private func setupEngine() {
        engine.attach(playerNode)
        engine.attach(reverb)
        reverb.loadFactoryPreset(currentStyle.reverbPreset)
        reverb.wetDryMix = currentStyle.reverbMix
        engine.connect(playerNode, to: reverb, format: nil)
        engine.connect(reverb, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = currentStyle.volume
    }

    // MARK: - スタイル変更時の再起動
    private func restartWithNewStyle() {
        noteIndex = 0
        playerNode.stop()
        reverb.loadFactoryPreset(currentStyle.reverbPreset)
        reverb.wetDryMix = currentStyle.reverbMix
        engine.mainMixerNode.outputVolume = currentStyle.volume
        if !playerNode.isPlaying {
            scheduleNextNote()
        }
    }

    // MARK: - 開始 / 停止
    func start() {
        guard isEnabled else { return }
        startEngine()
    }

    func stop() {
        stopEngine()
    }

    private func startEngine() {
        guard !isEngineRunning else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            isEngineRunning = true
            scheduleNextNote()
        } catch {
            print("BGM start error: \(error)")
        }
    }

    private func stopEngine() {
        guard isEngineRunning else { return }
        isEngineRunning = false
        playerNode.stop()
        engine.stop()
    }

    // MARK: - ノートスケジューリング
    private func scheduleNextNote() {
        guard isEngineRunning else { return }
        let melody = currentStyle.melody
        let note = melody[noteIndex % melody.count]
        noteIndex += 1

        let buffer = makeSoftTone(frequency: note.freq, duration: note.dur)

        playerNode.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
            guard let self, self.isEngineRunning else { return }
            let gap = Double.random(in: self.currentStyle.noteGap)
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + gap) {
                self.scheduleNextNote()
            }
        }

        if !playerNode.isPlaying { playerNode.play() }
    }

    // MARK: - PCM バッファ生成（ソフトサイン波）
    private func makeSoftTone(frequency: Double, duration: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let fadeSamples = Int(sampleRate * 0.38)
        guard let L = buffer.floatChannelData?[0],
              let R = buffer.floatChannelData?[1] else { return buffer }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate

            let fadeD = Double(fadeSamples)
            let env: Double
            if i < fadeSamples {
                let x = Double(i) / fadeD
                env = x * x * (3.0 - 2.0 * x)
            } else if i > Int(frameCount) - fadeSamples {
                let x = Double(Int(frameCount) - i) / fadeD
                env = x * x * (3.0 - 2.0 * x)
            } else {
                env = 1.0
            }

            let f = frequency
            let sample = env * 0.13 * (
                0.62 * sin(2.0 * .pi * f * t) +
                0.26 * sin(2.0 * .pi * f * 2.0 * t) +
                0.12 * sin(2.0 * .pi * f * 3.0 * t)
            )

            L[i] = Float(sample)
            R[i] = Float(sample)
        }

        return buffer
    }
}
