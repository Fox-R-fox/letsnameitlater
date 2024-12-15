import React from 'react';
import NoteList from './components/NoteList';
import AddNote from './components/AddNote';

function App() {
  return (
    <div>
      <h1>Notes App</h1>
      <AddNote />
      <NoteList />
    </div>
  );
}

export default App;
