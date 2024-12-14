const express = require('express');
const mongoose = require('mongoose');
const Note = require('./models/Note');

const app = express();
const port = 3000;

mongoose.connect('mongodb://mongo:27017/notes', { useNewUrlParser: true, useUnifiedTopology: true });

app.use(express.json());

app.get('/notes', async (req, res) => {
  const notes = await Note.find();
  res.json(notes);
});

app.post('/notes', async (req, res) => {
  const note = new Note(req.body);
  await note.save();
  res.json(note);
});

app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
