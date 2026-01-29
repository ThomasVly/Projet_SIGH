// ================================
// SIGH Admin - Firebase Integration (No Server Required)
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

// GitHub Configuration
const GITHUB_CONFIG = {
    owner: 'c-guill',
    repo: 'SIGH_PDF',
    branch: 'main',
    token: 'token'
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
const db = firebase.firestore();
const conseilsCollection = db.collection('conseil');

// DOM Elements
const conseilForm = document.getElementById('conseilForm');
const conseilsList = document.getElementById('conseilsList');
const refreshBtn = document.getElementById('refreshBtn');
const submitBtn = document.getElementById('submitBtn');
const toast = document.getElementById('toast');
const pdfCheckbox = document.getElementById('pdf');
const pdfUploadSection = document.getElementById('pdfUploadSection');
const pdfFileInput = document.getElementById('pdfFile');
const fileDisplay = document.getElementById('fileDisplay');
const detailField = document.getElementById('detail');
const typeInput = document.getElementById('type');
const btnTutorial = document.getElementById('btnTutorial');
const btnFiche = document.getElementById('btnFiche');

// Heating sliders
const heatingEnergySlider = document.getElementById('heatingEnergy');
const heatingTypeSlider = document.getElementById('heatingType');
const heatingEnergyValue = document.getElementById('heatingEnergyValue');
const heatingTypeValue = document.getElementById('heatingTypeValue');

// Heating slider configuration
const HEATING_ENERGY_OPTIONS = {
    0: { label: 'Chauffage électrique', tag: 'chauffage électrique', class: 'tag-electrique' },
    1: { label: 'Tout le monde', tag: null, class: '' },
    2: { label: 'Chauffage gaz', tag: 'chauffage gaz', class: 'tag-gaz' }
};

const HEATING_TYPE_OPTIONS = {
    0: { label: 'Chauffage collectif', tag: 'chauffage collectif', class: 'tag-collectif' },
    1: { label: 'Tout le monde', tag: null, class: '' },
    2: { label: 'Chauffage individuel', tag: 'chauffage individuel', class: 'tag-individuel' }
};

// Edit mode state
let editingId = null;
let editingPdfUrl = '';

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
// GitHub PDF Upload
// ================================
async function uploadPdfToGitHub(file, fileName) {
    if (!GITHUB_CONFIG.token) {
        throw new Error('Token GitHub requis pour uploader le PDF');
    }

    try {
        const base64Content = await fileToBase64(file);
        const timestamp = Date.now();
        const safeName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
        const uniqueFileName = `${timestamp}_${safeName}`;
        const apiUrl = `https://api.github.com/repos/${GITHUB_CONFIG.owner}/${GITHUB_CONFIG.repo}/contents/pdfs/${uniqueFileName}`;

        console.log('📤 Uploading PDF to GitHub:', uniqueFileName);

        const response = await fetch(apiUrl, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${GITHUB_CONFIG.token}`,
                'Content-Type': 'application/json',
                'Accept': 'application/vnd.github.v3+json'
            },
            body: JSON.stringify({
                message: `Add PDF: ${uniqueFileName}`,
                content: base64Content,
                branch: GITHUB_CONFIG.branch
            })
        });

        if (!response.ok) {
            const errorData = await response.json();
            console.error('GitHub API Error:', errorData);
            throw new Error(errorData.message || 'Erreur lors de l\'upload sur GitHub');
        }

        const data = await response.json();
        console.log('✅ PDF uploaded successfully:', data.content.html_url);

        const rawUrl = `https://raw.githubusercontent.com/${GITHUB_CONFIG.owner}/${GITHUB_CONFIG.repo}/${GITHUB_CONFIG.branch}/pdfs/${uniqueFileName}`;

        return {
            url: rawUrl,
            fileName: uniqueFileName,
            htmlUrl: data.content.html_url
        };
    } catch (error) {
        console.error('❌ Error uploading PDF:', error);
        throw error;
    }
}

function fileToBase64(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            resolve(base64);
        };
        reader.onerror = reject;
        reader.readAsDataURL(file);
    });
}

// ================================
// Conseil CRUD Operations
// ================================

async function addConseil(conseilData) {
    try {
        conseilData.timestamp = firebase.firestore.FieldValue.serverTimestamp();
        const docRef = await conseilsCollection.add(conseilData);
        console.log('✅ Conseil added with ID:', docRef.id);
        showToast('Conseil ajouté avec succès !', 'success');
        return docRef.id;
    } catch (error) {
        console.error('❌ Error adding conseil:', error);
        showToast('Erreur lors de l\'ajout du conseil', 'error');
        throw error;
    }
}

async function updateConseil(id, conseilData) {
    try {
        await conseilsCollection.doc(id).update(conseilData);
        console.log('✅ Conseil updated:', id);
        showToast('Conseil modifié avec succès !', 'success');
    } catch (error) {
        console.error('❌ Error updating conseil:', error);
        showToast('Erreur lors de la modification du conseil', 'error');
        throw error;
    }
}

async function getConseils() {
    try {
        const querySnapshot = await conseilsCollection.orderBy('timestamp', 'desc').get();
        const conseils = [];
        querySnapshot.forEach((doc) => {
            conseils.push({
                id: doc.id,
                ...doc.data()
            });
        });
        console.log('✅ Fetched', conseils.length, 'conseils');
        return conseils;
    } catch (error) {
        console.error('❌ Error fetching conseils:', error);
        // Fallback without ordering
        try {
            const querySnapshot = await conseilsCollection.get();
            const conseils = [];
            querySnapshot.forEach((doc) => {
                conseils.push({
                    id: doc.id,
                    ...doc.data()
                });
            });
            return conseils;
        } catch (fallbackError) {
            showToast('Erreur lors du chargement des conseils', 'error');
            throw fallbackError;
        }
    }
}

async function deleteConseil(id) {
    try {
        await conseilsCollection.doc(id).delete();
        console.log('✅ Conseil deleted:', id);
        showToast('Conseil supprimé', 'success');
    } catch (error) {
        console.error('❌ Error deleting conseil:', error);
        showToast('Erreur lors de la suppression', 'error');
        throw error;
    }
}

// ================================
// UI Rendering
// ================================

function formatDate(timestamp) {
    if (!timestamp) return 'Date inconnue';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }).format(date);
}

function renderConseils(conseils) {
    if (conseils.length === 0) {
        conseilsList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">📭</div>
                <p>Aucun conseil pour le moment</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Ajoutez votre premier conseil ci-dessus</p>
            </div>
        `;
        return;
    }

    conseilsList.innerHTML = conseils.map(conseil => `
        <div class="conseil-item" data-id="${conseil.id}">
            <div class="conseil-content">
                <h3 class="conseil-title">${escapeHtml(conseil.title || 'Sans titre')}</h3>
                <p class="conseil-description">${escapeHtml(conseil.description || 'Pas de description')}</p>
                ${conseil.detail ? `<p class="conseil-description" style="opacity: 0.7; font-size: 0.85rem;">${escapeHtml(conseil.detail)}</p>` : ''}
                <div class="conseil-meta">
                    ${conseil.type ? `<span class="conseil-type">${escapeHtml(conseil.type)}</span>` : ''}
                    ${conseil.pdf ? `<a href="${conseil.pdfUrl || conseil.detail || '#'}" target="_blank" class="conseil-pdf">📄 PDF</a>` : ''}
                    ${renderTags(conseil.tags)}
                    <span class="conseil-date">${formatDate(conseil.timestamp)}</span>
                </div>
            </div>
            <div class="conseil-actions">
                <button class="btn btn-secondary" onclick="handleEdit('${conseil.id}')">✏️ Modifier</button>
                <button class="btn btn-danger" onclick="handleDelete('${conseil.id}')">🗑️ Supprimer</button>
            </div>
        </div>
    `).join('');
}

function renderTags(tags) {
    if (!tags || tags.length === 0) return '';
    const tagArray = Array.isArray(tags) ? tags : Object.values(tags);
    return tagArray.map(tag => `<span class="conseil-tag">#${escapeHtml(tag)}</span>`).join('');
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
    conseilForm.reset();
    editingId = null;
    editingPdfUrl = '';
    submitBtn.querySelector('.btn-text').textContent = 'Ajouter le conseil';
    submitBtn.classList.remove('editing');

    // Reset PDF section
    pdfUploadSection.style.display = 'none';
    fileDisplay.classList.remove('has-file');
    fileDisplay.querySelector('.file-text').textContent = 'Cliquez pour sélectionner un PDF';
    fileDisplay.querySelector('.file-icon').textContent = '📁';

    // Reset detail field
    detailField.readOnly = false;
    detailField.placeholder = 'Lien de l\'article';
    detailField.style.backgroundColor = '';

    // Reset type toggle to tutorial
    typeInput.value = 'tutorial';
    btnTutorial.classList.add('active');

    // Reset heating sliders
    heatingEnergySlider.value = 1;
    heatingTypeSlider.value = 1;
    updateHeatingSliderDisplay();
    btnFiche.classList.remove('active');
}

function populateForm(conseil) {
    document.getElementById('title').value = conseil.title || '';
    document.getElementById('description').value = conseil.description || '';
    document.getElementById('tags').value = Array.isArray(conseil.tags) ? conseil.tags.join(', ') : '';

    // Set type toggle
    const typeValue = conseil.type || 'tutorial';
    typeInput.value = typeValue;
    if (typeValue === 'fiche') {
        btnFiche.classList.add('active');
        btnTutorial.classList.remove('active');
    } else {
        btnTutorial.classList.add('active');
        btnFiche.classList.remove('active');
    }

    // Handle PDF checkbox
    pdfCheckbox.checked = conseil.pdf || false;
    if (conseil.pdf) {
        pdfUploadSection.style.display = 'block';
        detailField.readOnly = true;
        detailField.value = conseil.detail || conseil.pdfUrl || '';
        detailField.placeholder = '📄 URL du PDF';
        detailField.style.backgroundColor = '#f0f4f8';
        editingPdfUrl = conseil.pdfUrl || conseil.detail || '';
    } else {
        pdfUploadSection.style.display = 'none';
        detailField.readOnly = false;
        detailField.value = conseil.detail || '';
        detailField.style.backgroundColor = '';
    }

    // Set heating sliders based on existing tags
    setHeatingSliderFromTags(conseil.tags);

    editingId = conseil.id;
    submitBtn.querySelector('.btn-text').textContent = '✏️ Modifier le conseil';
    submitBtn.classList.add('editing');

    conseilForm.scrollIntoView({ behavior: 'smooth' });
}

// ================================
// Event Handlers
// ================================

// Type toggle buttons
btnTutorial.addEventListener('click', () => {
    typeInput.value = 'tutorial';
    btnTutorial.classList.add('active');
    btnFiche.classList.remove('active');
});

btnFiche.addEventListener('click', () => {
    typeInput.value = 'fiche';
});

// Heating slider event listeners
function updateHeatingSliderDisplay() {
    const energyOption = HEATING_ENERGY_OPTIONS[heatingEnergySlider.value];
    const typeOption = HEATING_TYPE_OPTIONS[heatingTypeSlider.value];
    
    heatingEnergyValue.textContent = energyOption.label;
    heatingEnergyValue.className = 'slider-value ' + energyOption.class;
    
    heatingTypeValue.textContent = typeOption.label;
    heatingTypeValue.className = 'slider-value ' + typeOption.class;
}

heatingEnergySlider.addEventListener('input', updateHeatingSliderDisplay);
heatingTypeSlider.addEventListener('input', updateHeatingSliderDisplay);

// Initialize slider display
document.addEventListener('DOMContentLoaded', updateHeatingSliderDisplay);

// Helper function to get heating tags from sliders
function getHeatingTags() {
    const tags = [];
    const energyOption = HEATING_ENERGY_OPTIONS[heatingEnergySlider.value];
    const typeOption = HEATING_TYPE_OPTIONS[heatingTypeSlider.value];
    
    if (energyOption.tag) tags.push(energyOption.tag);
    if (typeOption.tag) tags.push(typeOption.tag);
    
    return tags;
}

// Helper function to set sliders based on existing tags
function setHeatingSliderFromTags(tags) {
    const tagArray = Array.isArray(tags) ? tags : [];
    
    // Energy slider
    if (tagArray.includes('chauffage électrique')) {
        heatingEnergySlider.value = 0;
    } else if (tagArray.includes('chauffage gaz')) {
        heatingEnergySlider.value = 2;
    } else {
        heatingEnergySlider.value = 1;
    }
    
    // Type slider
    if (tagArray.includes('chauffage collectif')) {
        heatingTypeSlider.value = 0;
    } else if (tagArray.includes('chauffage individuel')) {
        heatingTypeSlider.value = 2;
    } else {
        heatingTypeSlider.value = 1;
    }
    
    updateHeatingSliderDisplay();
}

// Filter out heating tags from user-entered tags (to avoid duplicates)
function filterHeatingTags(tags) {
    const heatingTagsList = ['chauffage électrique', 'chauffage gaz', 'chauffage collectif', 'chauffage individuel'];
    return tags.filter(tag => !heatingTagsList.includes(tag.toLowerCase()));
}

// Dummy placeholder to maintain the structure
(() => {
    btnFiche.classList.add('active');
    btnTutorial.classList.remove('active');
});

// PDF Checkbox toggle
pdfCheckbox.addEventListener('change', (e) => {
    if (e.target.checked) {
        pdfUploadSection.style.display = 'block';
        detailField.readOnly = true;
        detailField.value = editingPdfUrl || '';
        detailField.placeholder = '📄 L\'URL du PDF sera automatiquement insérée après upload';
        detailField.style.backgroundColor = '#f0f4f8';
    } else {
        pdfUploadSection.style.display = 'none';
        pdfFileInput.value = '';
        fileDisplay.classList.remove('has-file');
        fileDisplay.querySelector('.file-text').textContent = 'Cliquez pour sélectionner un PDF';
        fileDisplay.querySelector('.file-icon').textContent = '📁';
        detailField.readOnly = false;
        detailField.value = '';
        detailField.placeholder = 'Lien de l\'article';
        detailField.style.backgroundColor = '';
    }
});

// File input change
pdfFileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (file) {
        fileDisplay.classList.add('has-file');
        fileDisplay.querySelector('.file-text').textContent = file.name;
        fileDisplay.querySelector('.file-icon').textContent = '📄';
    } else {
        fileDisplay.classList.remove('has-file');
        fileDisplay.querySelector('.file-text').textContent = 'Cliquez pour sélectionner un PDF';
        fileDisplay.querySelector('.file-icon').textContent = '📁';
    }
});

// Form submission
conseilForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');

    btnText.style.display = 'none';
    btnLoader.style.display = 'inline';
    submitBtn.disabled = true;

    try {
        const formData = new FormData(conseilForm);
        const tagsInput = formData.get('tags');
        let tags = tagsInput
            ? tagsInput.split(',').map(tag => tag.trim()).filter(tag => tag.length > 0)
            : [];
        
        // Filter out existing heating tags and add new ones from sliders
        tags = filterHeatingTags(tags);
        const heatingTags = getHeatingTags();
        tags = [...tags, ...heatingTags];

        const hasPdf = formData.get('pdf') === 'on';
        let pdfUrl = editingPdfUrl;
        let pdfFileName = '';

        // Upload PDF if checked and new file selected
        if (hasPdf && pdfFileInput.files[0]) {
            try {
                showToast('📤 Upload du PDF en cours...', 'success');
                const uploadResult = await uploadPdfToGitHub(
                    pdfFileInput.files[0],
                    pdfFileInput.files[0].name
                );
                pdfUrl = uploadResult.url;
                pdfFileName = uploadResult.fileName;
                console.log('PDF URL:', pdfUrl);
            } catch (uploadError) {
                showToast(uploadError.message, 'error');
                throw uploadError;
            }
        }

        const conseilData = {
            title: formData.get('title'),
            description: formData.get('description'),
            detail: hasPdf ? pdfUrl : (formData.get('detail') || ''),
            type: formData.get('type'),
            pdf: hasPdf,
            pdfUrl: pdfUrl,
            pdfFileName: pdfFileName || '',
            tags: tags
        };

        if (editingId) {
            await updateConseil(editingId, conseilData);
        } else {
            await addConseil(conseilData);
        }

        resetForm();
        await loadConseils();
    } catch (error) {
        console.error('Form submission error:', error);
    } finally {
        btnText.style.display = 'inline';
        btnLoader.style.display = 'none';
        submitBtn.disabled = false;
    }
});

// Refresh button
refreshBtn.addEventListener('click', loadConseils);

// Delete handler (global for inline onclick)
window.handleDelete = async function (id) {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce conseil ?')) {
        await deleteConseil(id);
        if (editingId === id) {
            resetForm();
        }
        await loadConseils();
    }
};

// Edit handler (global for inline onclick)
window.handleEdit = async function (id) {
    try {
        const conseils = await getConseils();
        const conseil = conseils.find(c => c.id === id);
        if (conseil) {
            populateForm(conseil);
        }
    } catch (error) {
        console.error('Error loading conseil for edit:', error);
    }
};

// ================================
// Initialization
// ================================

async function loadConseils() {
    conseilsList.innerHTML = `
        <div class="loading-state">
            <div class="spinner"></div>
            <p>Chargement des conseils...</p>
        </div>
    `;

    try {
        const conseils = await getConseils();
        renderConseils(conseils);
    } catch (error) {
        conseilsList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">⚠️</div>
                <p>Erreur de connexion à Firebase</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Vérifiez votre connexion internet</p>
            </div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', loadConseils);

console.log('🚀 SIGH Admin - Conseils initialized (No Server Mode)');
