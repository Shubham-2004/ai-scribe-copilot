import express from 'express';
const router = express.Router();
import {
  createUploadSession,
  getPresignedUrl,
  notifyChunkUploaded,
  transcribeAudio
} from '../controllers/audioController.js';

router.post('/upload-session', createUploadSession);
router.post('/get-presigned-url', getPresignedUrl);
router.post('/notify-chunk-uploaded', notifyChunkUploaded);
router.post('/transcribe-audio', transcribeAudio);

export default router;