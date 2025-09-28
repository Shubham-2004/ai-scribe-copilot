import fs from 'fs';
import axios from 'axios';

const presignedUrl = 'https://yojlumklmggiqycatsch.supabase.co/storage/v1/object/upload/sign/audio-bucket/ba3246e9-be05-4388-a5e1-886bb030a3db/chunk_0.wav?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV82MjcyZmMxZS00ODJkLTRkMWUtYmIzZS1iZWFjNzNkMDEyMDQiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJhdWRpby1idWNrZXQvYmEzMjQ2ZTktYmUwNS00Mzg4LWE1ZTEtODg2YmIwMzBhM2RiL2NodW5rXzAud2F2IiwidXBzZXJ0IjpmYWxzZSwiaWF0IjoxNzU5MDg5NDk1LCJleHAiOjE3NTkwOTY2OTV9.2wCAAnn_Ubjz-MF9KbysqFiGu1Zz8FB0KDfqFd2GhQI';
const filePath = 'C:/Users/hrall/Desktop/StreamScript/stream_script_backend/song-english-edm-296526.mp3';

const fileStream = fs.createReadStream(filePath);

axios.put(presignedUrl, fileStream, {
  headers: { 'Content-Type': 'audio/mp3' }
})
  .then(res => console.log('Upload status:', res.status))
  .catch(err => console.error('Upload error:', err));