import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Note from './Note';

function NoteList() {
  const [notes, setNotes] = useState([]);

  useEffect(() => {
    const fetchNotes = async () => {
      const response = await axios.get('/notes');
      setNotes(response.data);
    };
    fetchNotes();
  }, []);

  return (
    <div>
      {notes.map((note) => (
        <Note key={note._id} note={note} />
      ))}
    </div>
  );
}

export default NoteList;
