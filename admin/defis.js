// ================================
// SIGH Admin - Défis Firebase Integration (No Server Required)
// ================================

// Firebase Configuration
const firebaseConfig = {
    apiKey: "AIzaSyDwqBca_lOuCcd7aTaYI5WoW1GDKndq2ho",
    authDomain: "sighg1-29498.firebaseapp.com",
    projectId: "sighg1-29498",
    storageBucket: "sighg1-29498.appspot.com",
    messagingSenderId: "35428473210",
    appId: "1:35428473210:web:2b4574b94feea1870b1ec3"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const challengesCollection = db.collection('challenges');

// DOM Elements
const defiForm = document.getElementById('defiForm');
const defisList = document.getElementById('defisList');
const refreshBtn = document.getElementById('refreshBtn');
const submitBtn = document.getElementById('submitBtn');
const toast = document.getElementById('toast');

// Edit mode state
let editingId = null;

// ================================
// Toast Notifications
// ================================
function showToast(message, type = 'success') {
    toast.textContent = message;
    toast.className = `toast ${type} show`;
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}

// ================================
// Défi CRUD Operations
// ================================

async function addDefi(defiData) {
    try {
        const docRef = await challengesCollection.add(defiData);
        console.log('✅ Défi added with ID:', docRef.id);
        showToast('Défi ajouté avec succès !', 'success');
        return docRef.id;
    } catch (error) {
        console.error('❌ Error adding défi:', error);
        showToast('Erreur lors de l\'ajout du défi', 'error');
        throw error;
    }
}

async function updateDefi(id, defiData) {
    try {
        await challengesCollection.doc(id).update(defiData);
        console.log('✅ Défi updated:', id);
        showToast('Défi modifié avec succès !', 'success');
    } catch (error) {
        console.error('❌ Error updating défi:', error);
        showToast('Erreur lors de la modification du défi', 'error');
        throw error;
    }
}

async function getDefis() {
    try {
        const querySnapshot = await challengesCollection.get();
        const defis = [];
        querySnapshot.forEach((doc) => {
            defis.push({
                id: doc.id,
                ...doc.data()
            });
        });
        console.log('✅ Fetched', defis.length, 'défis');
        return defis;
    } catch (error) {
        console.error('❌ Error fetching défis:', error);
        showToast('Erreur lors du chargement des défis', 'error');
        throw error;
    }
}

async function deleteDefi(id) {
    try {
        await challengesCollection.doc(id).delete();
        console.log('✅ Défi deleted:', id);
        showToast('Défi supprimé', 'success');
    } catch (error) {
        console.error('❌ Error deleting défi:', error);
        showToast('Erreur lors de la suppression', 'error');
        throw error;
    }
}

// ================================
// UI Rendering
// ================================

function renderDefis(defis) {
    if (defis.length === 0) {
        defisList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">🎯</div>
                <p>Aucun défi pour le moment</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Ajoutez votre premier défi ci-dessus</p>
            </div>
        `;
        return;
    }

    defisList.innerHTML = defis.map(defi => `
        <div class="conseil-item" data-id="${defi.id}">
            <div class="conseil-content">
                <h3 class="conseil-title">${escapeHtml(defi.title || 'Sans titre')}</h3>
                <p class="conseil-description">${escapeHtml(defi.description || 'Pas de description')}</p>
                <div class="conseil-meta">
                    ${defi.month ? `<span class="conseil-type">${escapeHtml(defi.month)}</span>` : ''}
                    ${defi.reward ? `<span class="conseil-tag">🏆 ${defi.reward} pts</span>` : ''}
                    ${defi.reminder ? `<span class="conseil-tag">⏰ ${escapeHtml(defi.reminder)}</span>` : ''}
                </div>
            </div>
            <div class="conseil-actions">
                <button class="btn btn-secondary" onclick="handleEdit('${defi.id}')">✏️ Modifier</button>
                <button class="btn btn-danger" onclick="handleDelete('${defi.id}')">🗑️ Supprimer</button>
            </div>
        </div>
    `).join('');
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// ================================
// Form Functions
// ================================

function resetForm() {
    defiForm.reset();
    editingId = null;
    submitBtn.querySelector('.btn-text').textContent = 'Ajouter le défi';
    submitBtn.classList.remove('editing');
}

function populateForm(defi) {
    document.getElementById('title').value = defi.title || '';
    document.getElementById('description').value = defi.description || '';
    document.getElementById('monthLabel').value = defi.month || '';
    document.getElementById('reward').value = defi.reward || '';
    document.getElementById('reminder').value = defi.reminder || '';

    editingId = defi.id;
    submitBtn.querySelector('.btn-text').textContent = '✏️ Modifier le défi';
    submitBtn.classList.add('editing');

    defiForm.scrollIntoView({ behavior: 'smooth' });
}

// ================================
// Event Handlers
// ================================

defiForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');

    btnText.style.display = 'none';
    btnLoader.style.display = 'inline';
    submitBtn.disabled = true;

    try {
        const formData = new FormData(defiForm);

        const defiData = {
            title: formData.get('title'),
            description: formData.get('description'),
            month: formData.get('monthLabel'),
            reward: parseInt(formData.get('reward')) || 0,
            reminder: formData.get('reminder') || ''
        };

        if (editingId) {
            await updateDefi(editingId, defiData);
        } else {
            await addDefi(defiData);
        }

        resetForm();
        await loadDefis();
    } catch (error) {
        console.error('Form submission error:', error);
    } finally {
        btnText.style.display = 'inline';
        btnLoader.style.display = 'none';
        submitBtn.disabled = false;
    }
});

refreshBtn.addEventListener('click', loadDefis);

window.handleDelete = async function (id) {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce défi ?')) {
        await deleteDefi(id);
        if (editingId === id) {
            resetForm();
        }
        await loadDefis();
    }
};

window.handleEdit = async function (id) {
    try {
        const defis = await getDefis();
        const defi = defis.find(d => d.id === id);
        if (defi) {
            populateForm(defi);
        }
    } catch (error) {
        console.error('Error loading défi for edit:', error);
    }
};

// ================================
// Initialization
// ================================

async function loadDefis() {
    defisList.innerHTML = `
        <div class="loading-state">
            <div class="spinner"></div>
            <p>Chargement des défis...</p>
        </div>
    `;

    try {
        const defis = await getDefis();
        renderDefis(defis);
    } catch (error) {
        defisList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">⚠️</div>
                <p>Erreur de connexion à Firebase</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Vérifiez votre connexion internet</p>
            </div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', loadDefis);

console.log('🚀 SIGH Admin - Défis initialized (No Server Mode)');
