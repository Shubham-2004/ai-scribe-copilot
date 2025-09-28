import express from 'express';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes.js';
import patientRoutes from './routes/patientRoutes.js';
import audioRoutes from './routes/audioRoutes.js';

dotenv.config();

const app = express();
app.use(bodyParser.json());

app.use('/auth', authRoutes);
app.use('/', patientRoutes);
app.use('/', audioRoutes);

app.get('/', (req, res) => {
  res.send('Supabase Auth API is running');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
