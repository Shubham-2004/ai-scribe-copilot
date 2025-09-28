const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

router.get('/patients', patientController.getPatients);
router.post('/add-patient-ext', patientController.addPatient);
router.get('/fetch-session-by-patient/:patientId', patientController.getSessionsByPatient);

module.exports = router;