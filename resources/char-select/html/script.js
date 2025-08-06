document.addEventListener('DOMContentLoaded', () => {
  let characters = [];
  let characterIdToDelete = null;
  let selectedPedModel = null;

  const availablePeds = [
    'a_m_m_afriamer_01',
    'a_m_m_beach_01',
    'a_m_m_bevhills_01',
    'a_m_y_skater_01',
    'a_f_m_bevhills_01',
    'a_f_m_fatwhite_01',
    'ig_denise',
    'cs_amandatownley',
    's_m_m_movprem_01',
    's_m_m_strvend_01',
  ];

  const characterMenu = document.getElementById('character-menu');
  const characterList = document.getElementById('character-list');

  const pedSelectModal = document.getElementById('ped-select-modal');
  const cancelSelectBtn = document.getElementById('cancel-ped-select-btn');
  const pedGrid = document.getElementById('ped-grid');

  const charNameModal = document.getElementById('char-name-modal');
  const nameCharForm = document.getElementById('name-char-form');
  const cancelCreateBtn = document.getElementById('cancel-name-btn');
  const firstNameInput = document.getElementById('first-name-input');
  const lastNameInput = document.getElementById('last-name-input');

  const deleteCharModal = document.getElementById('delete-char-modal');
  const deleteConfirmText = document.getElementById('delete-confirm-text');
  const confirmDeleteBtn = document.getElementById('confirm-delete-btn');
  const cancelDeleteBtn = document.getElementById('cancel-delete-btn');
  const createCharBtn = document.getElementById('create-char-btn');
  const confirmPedBtn = document.getElementById('next-btn');

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
      characters = data ? data.filter((char) => char !== null) : [];
      renderCharacterList();

      characterMenu.classList.remove('hidden');
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
      if (char !== null) {
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
      }
    });
  };

  const populatePedGrid = () => {
    pedGrid.innerHTML = '';
    availablePeds.forEach((model) => {
      const pedItem = document.createElement('div');
      pedItem.className = 'ped-item';
      pedItem.dataset.model = model;
      const pedImage = document.createElement('img');
      pedImage.src = `images/${model}.png`;
      pedImage.onerror = () => {
        pedImage.src = 'images/default.png';
      };
      pedItem.appendChild(pedImage);

      pedItem.addEventListener('click', () => {
        const currentlySelected = pedGrid.querySelector('.selected');
        if (currentlySelected) {
          currentlySelected.classList.remove('selected');
        }
        pedItem.classList.add('selected');
        selectedPedModel = model;
      });
      pedGrid.appendChild(pedItem);
    });
  };

  const selectCharacter = (characterId) => {
    characterMenu.classList.add('hidden');

    nuiRequest('selectCharacter', { cid: characterId });
  };

  const promptNameCharacter = () => {
    if (selectedPedModel !== null) {
      pedSelectModal.classList.add('hidden');
      charNameModal.classList.remove('hidden');
    }
  };

  const promptCreateCharacter = () => {
    selectedPedModel = null;
    populatePedGrid();
    pedSelectModal.classList.remove('hidden');
  };

  const handleCreateCharacter = (event) => {
    event.preventDefault();
    const firstName = firstNameInput.value.trim();
    const lastName = lastNameInput.value.trim();

    if (firstName && lastName) {
      nuiRequest('createCharacter', {
        firstname: firstName,
        lastname: lastName,
        model: selectedPedModel,
      });
      nameCharForm.reset();
      charNameModal.classList.add('hidden');
      selectedPedModel = null;
    }
  };

  const promptDeleteCharacter = (characterId) => {
    characterIdToDelete = characterId;
    const charToDelete = characters.find((c) => c && c.cid === characterId);

    if (charToDelete) {
      deleteConfirmText.textContent = `Are you sure you want to delete ${
        charToDelete.firstName + ' ' + charToDelete.lastName
      }?`;
      deleteCharModal.classList.remove('hidden');
    } else {
      console.error(`Character with ID ${characterId} not found.`);
    }
  };

  const executeDeleteCharacter = () => {
    if (characterIdToDelete !== null) {
      nuiRequest('deleteCharacter', { cid: characterIdToDelete });
      characters = characters.filter((c) => c && c.cid !== characterIdToDelete);
      renderCharacterList();
      characterIdToDelete = null;
      deleteCharModal.classList.add('hidden');
    }
  };

  createCharBtn.addEventListener('click', promptCreateCharacter);
  confirmPedBtn.addEventListener('click', promptNameCharacter);
  nameCharForm.addEventListener('submit', handleCreateCharacter);
  cancelCreateBtn.addEventListener('click', () => {
    nameCharForm.reset();
    charNameModal.classList.add('hidden');
  });
  cancelSelectBtn.addEventListener('click', () => {
    pedSelectModal.classList.add('hidden');
  });

  confirmDeleteBtn.addEventListener('click', executeDeleteCharacter);
  cancelDeleteBtn.addEventListener('click', () => {
    characterIdToDelete = null;
    deleteCharModal.classList.add('hidden');
  });
  renderCharacterList();
});
