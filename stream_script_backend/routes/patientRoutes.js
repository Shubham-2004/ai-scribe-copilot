const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY);

// GET /patients?userId={userId}
router.get('/patients', async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });

  const { data, error } = await supabase
    .from('patients')
    .select('*')
    .eq('user_id', userId);

  if (error) return res.status(500).json({ error: error.message });
  res.json({ patients: data });
});

// POST /add-patient-ext
router.post('/add-patient-ext', async (req, res) => {
  const { userId, name, dob, extra } = req.body;
  if (!userId || !name) return res.status(400).json({ error: 'Missing required fields' });

  const { data, error } = await supabase
    .from('patients')
    .insert([{ user_id: userId, name, dob, extra }])
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.json({ patient: data[0] });
});

// GET /fetch-session-by-patient/:patientId
router.get('/fetch-session-by-patient/:patientId', async (req, res) => {
  const { patientId } = req.params;
  if (!patientId) return res.status(400).json({ error: 'Missing patientId' });

  const { data, error } = await supabase
    .from('sessions')
    .select('*')
    .eq('patient_id', patientId);

  if (error) return res.status(500).json({ error: error.message });
  res.json({ sessions: data });
});

module.exports = router;