import Foundation
import AVFoundation

class VoiceRecorder: NSObject {
    private var audioRecorder: AVAudioRecorder?
    private var completion: ((URL?) -> Void)?
    
    init(completion: @escaping (URL?) -> Void) {
        self.completion = completion
        super.init()
    }
    
    /// Start recording audio to a temporary file.
    func startRecording() {
        // Ensure any ongoing recording is stopped.
        if audioRecorder?.isRecording == true {
            stopRecording()
        }
        
        // Request microphone permissions.
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if granted {
                    self.beginRecording()
                } else {
                    print("Microphone permission denied.")
                    self.completion?(nil)
                }
            }
        }
    }
    
    /// Stops the audio recording and triggers the completion handler.
    func stopRecording() {
        guard let recorder = audioRecorder, recorder.isRecording else {
            completion?(nil)
            return
        }
        
        recorder.stop()
        audioRecorder = nil
    }
    
    /// Internal function to set up and start the recording.
    private func beginRecording() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
            completion?(nil)
        }
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // Call completion with the recorded file URL if successful, otherwise pass nil.
        if flag {
            completion?(recorder.url)
        } else {
            print("Recording failed.")
            completion?(nil)
        }
    }
}
