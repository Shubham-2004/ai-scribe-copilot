import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:stream_script/core/components/custom_appbar.dart';
import 'package:uuid/uuid.dart';

// --- Configuration ---
const String _backendBaseUrl = 'https://streamscript.onrender.com'; 
const int _audioChunkDurationSeconds = 15;

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioService _audioService = AudioService();
  StreamSubscription? _statusSubscription;
  RecordingStatus _status = RecordingStatus.uninitialized();
  String? _transcribedText;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _statusSubscription = _audioService.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
    _audioService.initialize();
  }

  Future<void> _toggleRecording() async {
    if (_status.isRecording) return;
    await _audioService.startRecording();
  }

  Future<void> _stopAndUpload() async {
    if (!_status.isRecording) return;
    
    setState(() => _isProcessing = true);
    final transcript = await _audioService.stopRecordingAndUpload();
    setState(() {
      _transcribedText = transcript;
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: "Patients Consultation Recorder"),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRecordButton(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _status.isRecording ? _stopAndUpload : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _status.isRecording ? Colors.redAccent : Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text("OK / Stop & Upload"),
                  ),
                ),
                const SizedBox(height: 30),
                if (_transcribedText != null)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Transcribed Text:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _transcribedText!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                  fontFamily: 'Montserrat',
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _status.isRecording
                ? [Colors.redAccent, Colors.red.shade700]
                : [Colors.tealAccent, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _status.isRecording ? Colors.red.withOpacity(0.4) : Colors.teal.withOpacity(0.4),
              blurRadius: 32,
              spreadRadius: 8,
            )
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 5,
          ),
        ),
        child: Center(
          child: _isProcessing
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 4)
              : Icon(
                  _status.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 90,
                ),
        ),
      ),
    );
  }
}

// ---------------- Audio Service ----------------
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final ApiClient _apiClient = ApiClient();
  final StreamController<RecordingStatus> _statusController = StreamController.broadcast();
  Stream<RecordingStatus> get statusStream => _statusController.stream;

  RecordingStatus _currentStatus = RecordingStatus.uninitialized();
  Timer? _chunkTimer;
  String? _currentChunkPath;
  String? _sessionId;
  int _chunkCounter = 0;
  bool _isRecordingChunk = false;
  List<String> _uploadedChunkPaths = [];

  Future<void> initialize() async {
    _updateStatus(queueSize: 0);
  }

  Future<void> startRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _updateStatus(error: 'Microphone permission denied.');
      return;
    }

    _sessionId = await _apiClient.createUploadSession();
    if (_sessionId == null) {
      _updateStatus(error: 'Failed to create upload session.');
      return;
    }

    _chunkCounter = 0;
    _uploadedChunkPaths.clear();
    _updateStatus(isRecording: true, sessionId: _sessionId);

    _startChunking();
  }

  void _startChunking() {
    _recordNextChunk();
    _chunkTimer = Timer.periodic(
      const Duration(seconds: _audioChunkDurationSeconds),
      (timer) async {
        await _finishCurrentChunk();
        _recordNextChunk();
      },
    );
  }

  Future<void> _recordNextChunk() async {
    if (_isRecordingChunk) return;
    
    try {
      _isRecordingChunk = true;
      final dir = await getApplicationDocumentsDirectory();
      final chunkId = const Uuid().v4();
      _currentChunkPath = '${dir.path}/chunk_$chunkId.m4a';

      if (_currentChunkPath != null) {
        await _recorder.start(const RecordConfig(), path: _currentChunkPath!);
        _updateStatus(queueSize: _chunkCounter);
      } else {
        _updateStatus(error: 'Chunk path is null.');
      }
    } catch (e) {
      _updateStatus(error: 'Error starting chunk recording: $e');
      _isRecordingChunk = false;
    }
  }

  Future<void> _finishCurrentChunk() async {
    if (!_isRecordingChunk) return;
    
    try {
      await _recorder.stop();
      _isRecordingChunk = false;
      
      if (_currentChunkPath != null && _sessionId != null && File(_currentChunkPath!).existsSync()) {
        final file = File(_currentChunkPath!);
        final storagePath = await _apiClient.uploadChunk(
          sessionId: _sessionId!, 
          chunkOrder: _chunkCounter, 
          file: file
        );
        
        if (storagePath != null) {
          _uploadedChunkPaths.add(storagePath);
          _chunkCounter++;
        }
        
        // Clean up local file after upload
        file.deleteSync();
      }
    } catch (e) {
      _updateStatus(error: 'Error finishing chunk: $e');
      _isRecordingChunk = false;
    }
  }

  Future<String?> stopRecordingAndUpload() async {
    _chunkTimer?.cancel();
    await _finishCurrentChunk();
    _updateStatus(isRecording: false);

    // Get the final transcript by processing all uploaded chunks
    final transcript = await _apiClient.processSessionTranscript(
      sessionId: _sessionId!, 
      chunkPaths: _uploadedChunkPaths
    );
    return transcript;
  }

  void _updateStatus({bool? isRecording, String? sessionId, int? queueSize, String? error}) {
    _currentStatus = _currentStatus.copyWith(
      isRecording: isRecording ?? _currentStatus.isRecording,
      sessionId: sessionId ?? _currentStatus.sessionId,
      queueSize: queueSize ?? _currentStatus.queueSize,
      error: error ?? _currentStatus.error,
    );
    if (!_statusController.isClosed) _statusController.add(_currentStatus);
  }

  void dispose() {
    _chunkTimer?.cancel();
    _statusController.close();
    _recorder.dispose();
  }
}

// ---------------- API Client ----------------
class ApiClient {
  final http.Client _client = http.Client();

  Future<String?> createUploadSession() async {
    try {
      final resp = await _client.post(
        Uri.parse('$_backendBaseUrl/upload-session'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        return data['sessionId'];
      } else {
        print('Failed to create upload session: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('Error creating upload session: $e');
    }
    return null;
  }

  Future<String?> uploadChunk({required String sessionId, required int chunkOrder, required File file}) async {
    try {
      // Step 1: Get presigned URL
      final presignedUrlResp = await _client.post(
        Uri.parse('$_backendBaseUrl/get-presigned-url'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'chunkOrder': chunkOrder,
        }),
      );

      if (presignedUrlResp.statusCode != 200) {
        print('Failed to get presigned URL: ${presignedUrlResp.statusCode} - ${presignedUrlResp.body}');
        return null;
      }

      final presignedData = jsonDecode(presignedUrlResp.body);
      final presignedUrl = presignedData['presignedUrl'];
      final storagePath = presignedData['path'];

      // Step 2: Upload file using presigned URL
      final fileBytes = await file.readAsBytes();
      final uploadResp = await http.put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': 'audio/m4a',
        },
        body: fileBytes,
      );

      if (uploadResp.statusCode != 200) {
        print('Failed to upload chunk: ${uploadResp.statusCode} - ${uploadResp.body}');
        return null;
      }

      // Step 3: Notify backend about successful upload
      final notifyResp = await _client.post(
        Uri.parse('$_backendBaseUrl/notify-chunk-uploaded'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'chunkOrder': chunkOrder,
          'storagePath': storagePath,
        }),
      );

      if (notifyResp.statusCode != 200) {
        print('Failed to notify chunk upload: ${notifyResp.statusCode} - ${notifyResp.body}');
        return null;
      }

      print('Successfully uploaded chunk $chunkOrder for session $sessionId');
      return storagePath;
    } catch (e) {
      print('Error uploading chunk: $e');
      return null;
    }
  }

  Future<String?> processSessionTranscript({required String sessionId, required List<String> chunkPaths}) async {
    try {
      // Transcribe each chunk and combine results
      final allTranscripts = <String>[];
      
      for (final storagePath in chunkPaths) {
        final transcript = await _transcribeSingleChunk(storagePath);
        if (transcript != null && transcript.isNotEmpty) {
          allTranscripts.add(transcript);
        }
      }
      
      if (allTranscripts.isEmpty) {
        return "No audio transcribed. Please try again.";
      }
      
      return allTranscripts.join('\n\n');
    } catch (e) {
      print('Error processing session transcript: $e');
      return "Error processing transcription: $e";
    }
  }

  Future<String?> _transcribeSingleChunk(String storagePath) async {
    try {
      final resp = await _client.post(
        Uri.parse('$_backendBaseUrl/transcribe-audio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'storagePath': storagePath,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['transcription'] ?? data['transcript'];
      } else {
        print('Failed to transcribe chunk: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('Error transcribing chunk: $e');
    }
    return null;
  }
}

// ---------------- Status ----------------
class RecordingStatus {
  final bool isRecording;
  final String? sessionId;
  final int queueSize;
  final String? error;

  RecordingStatus({
    required this.isRecording,
    this.sessionId,
    required this.queueSize,
    this.error,
  });

  factory RecordingStatus.uninitialized() => RecordingStatus(isRecording: false, queueSize: 0);

  RecordingStatus copyWith({bool? isRecording, String? sessionId, int? queueSize, String? error}) =>
      RecordingStatus(
        isRecording: isRecording ?? this.isRecording,
        sessionId: sessionId ?? this.sessionId,
        queueSize: queueSize ?? this.queueSize,
        error: error ?? this.error,
      );
}