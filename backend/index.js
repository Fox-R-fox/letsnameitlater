const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Note = require('./models/Note');

const app = express();
const port = 3000;

// Enable CORS
app.use(cors());

// Connect to MongoDB (use the MongoDB service name as `mongo` in the Kubernetes cluster)
mongoose.connect('mongodb://mongo:27017/notes', { useNewUrlParser: true, useUnifiedTopology: true });

// Middleware to parse incoming JSON requests
app.use(express.json());

// Route to fetch all notes
app.get('/notes', async (req, res) => {
  const notes = await Note.find();
  res.json(notes);
});

// Route to add a new note
app.post('/notes', async (req, res) => {
  const note = new Note(req.body);
  await note.save();
  res.json(note);
});

// Listen on the specified port
app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
