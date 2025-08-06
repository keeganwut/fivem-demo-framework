document.addEventListener('DOMContentLoaded', () => {
  let characters = [];
  let characterIdToDelete = null;

  const characterList = document.getElementById('character-list');
  const createCharBtn = document.getElementById('create-char-btn');

  const createCharModal = document.getElementById('create-char-modal');
  const createCharForm = document.getElementById('create-char-form');
  const cancelCreateBtn = document.getElementById('cancel-create-btn');
  const firstNameInput = document.getElementById('first-name-input');
  const lastNameInput = document.getElementById('last-name-input');

  const deleteCharModal = document.getElementById('delete-char-modal');
  const deleteConfirmText = document.getElementById('delete-confirm-text');
  const confirmDeleteBtn = document.getElementById('confirm-delete-btn');
  const cancelDeleteBtn = document.getElementById('cancel-delete-btn');

  const nuiRequest = async (eventName, data = {}) => {
    try {
      const response = await fetch(
        `https://${GetParentResourceName()}/${eventName}`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: JSON.stringify(data),
        }
      );
      return await response.json();
    } catch (error) {
      console.error(`NUI Request Failed: ${eventName}`, error);
      return null;
    }
  };

  window.addEventListener('message', (event) => {
    const { action, data } = event.data;
    if (action === 'setupCharacters') {
      characters = data;
      renderCharacterList();
    }
  });

  const renderCharacterList = () => {
    characterList.innerHTML = '';

    if (!characters || characters.length === 0) {
      characterList.innerHTML =
        '<p style="text-align:center; color: #888;">No characters found.</p>';
      return;
    }

    characters.forEach((char) => {
      const entryDiv = document.createElement('div');
      entryDiv.className = 'character-entry';

      const charButton = document.createElement('button');
      charButton.className = 'menu-btn character-btn';
      charButton.textContent = char.firstName + ' ' + char.lastName;
      charButton.dataset.characterId = char.cid;

      const deleteButton = document.createElement('button');
      deleteButton.className = 'menu-btn delete-btn';
      deleteButton.innerHTML = '&times;';
      deleteButton.dataset.characterId = char.cid;

      charButton.addEventListener('click', () => selectCharacter(char.cid));
      deleteButton.addEventListener('click', (event) => {
        event.stopPropagation();
        promptDeleteCharacter(char.cid);
      });

      entryDiv.appendChild(charButton);
      entryDiv.appendChild(deleteButton);
      characterList.appendChild(entryDiv);
    });
  };

  const selectCharacter = (characterId) => {
    nuiRequest('selectCharacter', { cid: characterId });
  };

  const promptCreateCharacter = () => {
    createCharModal.classList.remove('hidden');
  };

  const handleCreateCharacter = (event) => {
    event.preventDefault();
    const firstName = firstNameInput.value.trim();
    const lastName = lastNameInput.value.trim();

    if (firstName && lastName) {
      nuiRequest('createCharacter', {
        firstname: firstName,
        lastname: lastName,
      });
      createCharForm.reset();
      createCharModal.classList.add('hidden');
    }
  };

  const promptDeleteCharacter = (characterId) => {
    characterIdToDelete = characterId;
    const charToDelete = characters.find((c) => c.cid === characterId);
    deleteConfirmText.textContent = `Are you sure you want to delete ${charToDelete.name}?`;
    deleteCharModal.classList.remove('hidden');
  };

  const executeDeleteCharacter = () => {
    if (characterIdToDelete !== null) {
      nuiRequest('deleteCharacter', { cid: characterIdToDelete });
      characters = characters.filter((c) => c.cid !== characterIdToDelete);
      renderCharacterList();
      characterIdToDelete = null;
      deleteCharModal.classList.add('hidden');
    }
  };

  createCharBtn.addEventListener('click', promptCreateCharacter);
  createCharForm.addEventListener('submit', handleCreateCharacter);
  cancelCreateBtn.addEventListener('click', () => {
    createCharForm.reset();
    createCharModal.classList.add('hidden');
  });

  confirmDeleteBtn.addEventListener('click', executeDeleteCharacter);
  cancelDeleteBtn.addEventListener('click', () => {
    characterIdToDelete = null;
    deleteCharModal.classList.add('hidden');
  });
  renderCharacterList();
});
