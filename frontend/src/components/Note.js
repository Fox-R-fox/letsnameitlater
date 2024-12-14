import React from 'react';

function Note({ note }) {
  return (
    <div>
      <h2>{note.title}</h2>
      <p>{note.content}</p>
    </div>
  );
}

export default Note;
