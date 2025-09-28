import { supabase } from '../supabaseClient.js';
import fs from "fs";
import Groq from "groq-sdk";

const AUDIO_BUCKET = 'audio-bucket'; // Supabase storage bucket name

/**
 * Utility: Respond with error and log
 */
const respondError = (res, status, message, details = null) => {
  if (details) console.error(message, details);
  else console.error(message);
  res.status(status).json({ error: message, details });
};

/**
 * @desc    Starts a new recording session.
 * @route   POST /v1/upload-session
 */
export const createUploadSession = async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('upload_sessions')
      .insert([{ status: 'active' }])
      .select()
      .single();

    if (error) return respondError(res, 500, 'Could not create upload session.', error.message);

    console.log(`[OK] Created new session: ${data.id}`);
    res.status(201).json({ sessionId: data.id });
  } catch (err) {
    respondError(res, 500, 'An unexpected error occurred.', err);
  }
};

/**
 * @desc    Generates a secure, temporary URL for uploading a single audio chunk.
 * @route   POST /v1/get-presigned-url
 */
export const getPresignedUrl = async (req, res) => {
  const { sessionId, chunkOrder } = req.body;
  if (!sessionId || typeof chunkOrder === 'undefined') {
    return respondError(res, 400, 'sessionId and chunkOrder are required.');
  }

  try {
    // Verify session exists and is active
    const { data: session, error: sessionError } = await supabase
      .from('upload_sessions')
      .select('id, status')
      .eq('id', sessionId)
      .single();

    if (sessionError || !session) return respondError(res, 404, `Session with ID ${sessionId} not found.`);
    if (session.status !== 'active') return respondError(res, 403, `Session ${sessionId} is not active.`);

    const path = `${sessionId}/chunk_${chunkOrder}.wav`;
    const { data, error } = await supabase
      .storage
      .from(AUDIO_BUCKET)
      .createSignedUploadUrl(path);

    if (error) return respondError(res, 500, 'Could not generate signed URL.', error.message);

    console.log(`[OK] Generated presigned URL for session ${sessionId}, chunk ${chunkOrder}`);
    res.status(200).json({ presignedUrl: data.signedUrl, path: data.path });
  } catch (err) {
    respondError(res, 500, 'An unexpected error occurred.', err);
  }
};

/**
 * @desc    Confirms that a chunk has been successfully uploaded to storage.
 * @route   POST /v1/notify-chunk-uploaded
 */
export const notifyChunkUploaded = async (req, res) => {
  const { sessionId, chunkOrder, storagePath } = req.body;
  if (!sessionId || typeof chunkOrder === 'undefined' || !storagePath) {
    return respondError(res, 400, 'sessionId, chunkOrder, and storagePath are required.');
  }

  try {
    const { error } = await supabase
      .from('audio_chunks')
      .insert([{
        session_id: sessionId,
        chunk_order: chunkOrder,
        storage_path: storagePath,
        status: 'uploaded',
      }]);

    if (error) {
      if (error.code === '23505') {
        // Unique constraint violation (chunk already recorded)
        return res.status(200).json({ message: 'Chunk upload was already recorded.' });
      }
      return respondError(res, 500, 'Could not record chunk upload.', error.message);
    }

    console.log(`[OK] Notified upload for session ${sessionId}, chunk ${chunkOrder}`);
    res.status(200).json({ message: 'Chunk upload successfully recorded.' });
  } catch (err) {
    respondError(res, 500, 'An unexpected error occurred.', err);
  }
};

/**
 * @desc    Transcribes an audio file using Groq API.
 * @route   POST /v1/transcribe-audio
 */
export const transcribeAudio = async (req, res) => {
  const { storagePath } = req.body;
  if (!storagePath) {
    return respondError(res, 400, 'storagePath is required.');
  }

  try {
    // Download the file from Supabase Storage
    const { data, error } = await supabase
      .storage
      .from(AUDIO_BUCKET)
      .download(storagePath);

    if (error || !data) {
      return respondError(res, 404, 'Audio file not found in storage.', error?.message);
    }

    // Save the file locally (for Groq SDK)
    const localPath = `./temp_${Date.now()}.m4a`;
    fs.writeFileSync(localPath, Buffer.from(await data.arrayBuffer()));

    // Transcribe using Groq
    const groq = new Groq({ apiKey: "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" });
    const transcription = await groq.audio.transcriptions.create({
      file: fs.createReadStream(localPath),
      model: "whisper-large-v3",
      response_format: "verbose_json",
    });

    // Clean up temp file
    fs.unlinkSync(localPath);

    // Return transcription result
    res.status(200).json({ transcription: transcription.text });
  } catch (err) {
    respondError(res, 500, 'Transcription failed.', err);
  }
};