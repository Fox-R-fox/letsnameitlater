// server.js
const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

// Enable CORS
app.use(cors());

// Example route to fetch notes
app.get('/notes', (req, res) => {
  // Logic to return notes
  res.json({ notes: [] });
});

app.listen(port, () => {
  console.log(`Backend service running on http://localhost:${port}`);
});
