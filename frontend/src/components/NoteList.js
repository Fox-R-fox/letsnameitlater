import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Note from './Note';

function NoteList() {
  const [notes, setNotes] = useState([]);

  useEffect(() => {
    const fetchNotes = async () => {
      try {
        // Update the URL to include the base URL of your backend service
        const response = await axios.get('http://a3032c65405ba426cb88a976277a40e6-996365679.us-east-1.elb.amazonaws.com/notes');
        setNotes(response.data);
      } catch (error) {
        console.error('Error fetching notes:', error);
      }
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
