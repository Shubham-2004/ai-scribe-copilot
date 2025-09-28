import express from 'express';
import { getPatients, addPatient, getSessionsByPatient } from '../controllers/patientController.js';
const router = express.Router();

router.get('/patients', getPatients);
router.post('/add-patient-ext', addPatient);
router.get('/fetch-session-by-patient/:patientId', getSessionsByPatient);

export default router;