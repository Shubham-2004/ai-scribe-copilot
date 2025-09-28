const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(bodyParser.json());

app.use('/auth', authRoutes);

app.get('/', (req, res) => {
  res.send('Supabase Auth API is running');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
