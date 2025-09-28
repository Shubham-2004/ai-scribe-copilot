import { supabase } from '../supabaseClient.js';

// GET /url/patients?userId={userId}
export const getPatients = async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });

  const { data, error } = await supabase
    .from('patients')
    .select('*')
    .eq('user_id', userId);

  if (error) return res.status(500).json({ error: error.message });
  res.json({ patients: data });
};

// POST /url/add-patient-ext
export const addPatient = async (req, res) => {
  const { userId, name, dob, extra } = req.body;
  if (!userId || !name) return res.status(400).json({ error: 'Missing required fields' });

  const { data, error } = await supabase
    .from('patients')
    .insert([{ user_id: userId, name, dob, extra }])
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.json({ patient: data[0] });
};

// GET /url/fetch-session-by-patient/:patientId
export const getSessionsByPatient = async (req, res) => {
  const { patientId } = req.params;
  if (!patientId) return res.status(400).json({ error: 'Missing patientId' });

  const { data, error } = await supabase
    .from('sessions')
    .select('*')
    .eq('patient_id', patientId);

  if (error) return res.status(500).json({ error: error.message });
  res.json({ sessions: data });
};