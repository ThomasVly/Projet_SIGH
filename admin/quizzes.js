// ================================
// SIGH Admin - Quiz Firebase Integration (No Server Required)
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
const quizzesCollection = db.collection('quizzes');

// DOM Elements
const quizForm = document.getElementById('quizForm');
const quizzesList = document.getElementById('quizzesList');
const refreshBtn = document.getElementById('refreshBtn');
const submitBtn = document.getElementById('submitBtn');
const toast = document.getElementById('toast');
const questionsContainer = document.getElementById('questionsContainer');
const addQuestionBtn = document.getElementById('addQuestionBtn');
const themeColorInput = document.getElementById('themeColor');
const colorHexDisplay = document.getElementById('colorHex');

// Edit mode state
let editingId = null;
let questionCount = 0;

// Color picker hex display update
themeColorInput.addEventListener('input', (e) => {
    colorHexDisplay.textContent = e.target.value.toUpperCase();
});

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
// Quiz CRUD Operations
// ================================

async function addQuiz(quizData) {
    try {
        const docRef = await quizzesCollection.add(quizData);
        console.log('✅ Quiz added with ID:', docRef.id);
        showToast('Quiz ajouté avec succès !', 'success');
        return docRef.id;
    } catch (error) {
        console.error('❌ Error adding quiz:', error);
        showToast('Erreur lors de l\'ajout du quiz', 'error');
        throw error;
    }
}

async function updateQuiz(id, quizData) {
    try {
        await quizzesCollection.doc(id).update(quizData);
        console.log('✅ Quiz updated:', id);
        showToast('Quiz modifié avec succès !', 'success');
    } catch (error) {
        console.error('❌ Error updating quiz:', error);
        showToast('Erreur lors de la modification du quiz', 'error');
        throw error;
    }
}

async function getQuizzes() {
    try {
        const querySnapshot = await quizzesCollection.get();
        const quizzes = [];
        querySnapshot.forEach((doc) => {
            quizzes.push({
                id: doc.id,
                ...doc.data()
            });
        });
        console.log('✅ Fetched', quizzes.length, 'quizzes');
        return quizzes;
    } catch (error) {
        console.error('❌ Error fetching quizzes:', error);
        showToast('Erreur lors du chargement des quiz', 'error');
        throw error;
    }
}

async function deleteQuiz(id) {
    try {
        await quizzesCollection.doc(id).delete();
        console.log('✅ Quiz deleted:', id);
        showToast('Quiz supprimé', 'success');
    } catch (error) {
        console.error('❌ Error deleting quiz:', error);
        showToast('Erreur lors de la suppression', 'error');
        throw error;
    }
}

// ================================
// Questions Management
// ================================

function createQuestionBlock(index, questionData) {
    questionData = questionData || null;
    const questionBlock = document.createElement('div');
    questionBlock.className = 'question-block';
    questionBlock.dataset.index = index;

    let optionsHtml;
    if (questionData && questionData.options) {
        optionsHtml = questionData.options.map((opt, i) => createOptionRowHtml(index, i, opt, questionData.answer === i)).join('');
    } else {
        optionsHtml = createOptionRowHtml(index, 0, '', true) + createOptionRowHtml(index, 1, '', false);
    }

    const questionText = questionData ? (questionData.question || '') : '';
    const explanationText = questionData ? (questionData.explanation || '') : '';

    questionBlock.innerHTML = `
        <div class="question-header">
            <span class="question-number">Question ${index + 1}</span>
            <button type="button" class="btn-remove-question" onclick="removeQuestion(${index})">✕ Supprimer</button>
        </div>
        <div class="form-group">
            <label>Question</label>
            <textarea class="question-text" rows="2" required placeholder="Posez votre question ici">${escapeHtml(questionText)}</textarea>
        </div>
        <div class="form-group">
            <label>Explication</label>
            <textarea class="question-explanation" rows="2" required placeholder="Explication de la bonne réponse">${escapeHtml(explanationText)}</textarea>
        </div>
        <div class="form-group">
            <label>Options de réponse (sélectionnez la bonne réponse)</label>
            <div class="options-container" data-question="${index}">
                ${optionsHtml}
            </div>
            <button type="button" class="btn btn-secondary btn-sm" onclick="addOptionToQuestion(${index})" style="margin-top: 0.5rem;">
                ➕ Option
            </button>
        </div>
    `;

    return questionBlock;
}

function createOptionRowHtml(questionIndex, optionIndex, value, checked) {
    value = value || '';
    checked = checked || false;
    return `
        <div class="option-row">
            <input type="radio" name="correctAnswer_${questionIndex}" value="${optionIndex}" ${checked ? 'checked' : ''}>
            <input type="text" class="option-input" placeholder="Option ${optionIndex + 1}" required value="${escapeHtml(value)}">
            <button type="button" class="btn-remove-option" onclick="removeOptionFromQuestion(this)">✕</button>
        </div>
    `;
}

function addQuestion(questionData) {
    questionData = questionData || null;
    const questionBlock = createQuestionBlock(questionCount, questionData);
    questionsContainer.appendChild(questionBlock);
    questionCount++;
    updateQuestionNumbers();
    updateRemoveQuestionButtons();
}

window.removeQuestion = function (index) {
    const block = questionsContainer.querySelector('.question-block[data-index="' + index + '"]');
    if (block) {
        block.remove();
        updateQuestionNumbers();
        updateRemoveQuestionButtons();
    }
};

window.addOptionToQuestion = function (questionIndex) {
    const container = document.querySelector('.options-container[data-question="' + questionIndex + '"]');
    if (container) {
        const optionRows = container.querySelectorAll('.option-row');
        const newIndex = optionRows.length;
        const optionRow = document.createElement('div');
        optionRow.className = 'option-row';
        optionRow.innerHTML = `
            <input type="radio" name="correctAnswer_${questionIndex}" value="${newIndex}">
            <input type="text" class="option-input" placeholder="Option ${newIndex + 1}" required>
            <button type="button" class="btn-remove-option" onclick="removeOptionFromQuestion(this)">✕</button>
        `;
        container.appendChild(optionRow);
        updateOptionRemoveButtons(container);
    }
};

window.removeOptionFromQuestion = function (btn) {
    const optionRow = btn.closest('.option-row');
    const container = optionRow.closest('.options-container');
    optionRow.remove();

    const optionRows = container.querySelectorAll('.option-row');
    optionRows.forEach((row, index) => {
        const radio = row.querySelector('input[type="radio"]');
        radio.value = index;
    });

    updateOptionRemoveButtons(container);
};

function updateOptionRemoveButtons(container) {
    const optionRows = container.querySelectorAll('.option-row');
    optionRows.forEach(row => {
        const removeBtn = row.querySelector('.btn-remove-option');
        removeBtn.style.display = optionRows.length > 2 ? 'inline-flex' : 'none';
    });
}

function updateQuestionNumbers() {
    const blocks = questionsContainer.querySelectorAll('.question-block');
    blocks.forEach((block, index) => {
        block.dataset.index = index;
        block.querySelector('.question-number').textContent = 'Question ' + (index + 1);

        const optionsContainer = block.querySelector('.options-container');
        optionsContainer.dataset.question = index;

        const radios = block.querySelectorAll('input[type="radio"]');
        radios.forEach(radio => {
            radio.name = 'correctAnswer_' + index;
        });

        const addOptBtn = block.querySelector('.btn-sm');
        addOptBtn.setAttribute('onclick', 'addOptionToQuestion(' + index + ')');

        const removeQBtn = block.querySelector('.btn-remove-question');
        removeQBtn.setAttribute('onclick', 'removeQuestion(' + index + ')');
    });
    questionCount = blocks.length;
}

function updateRemoveQuestionButtons() {
    const blocks = questionsContainer.querySelectorAll('.question-block');
    blocks.forEach(block => {
        const removeBtn = block.querySelector('.btn-remove-question');
        removeBtn.style.display = blocks.length > 1 ? 'inline-flex' : 'none';
    });
}

function getQuestionsFromForm() {
    const blocks = questionsContainer.querySelectorAll('.question-block');
    const questions = [];

    blocks.forEach((block, index) => {
        const questionText = block.querySelector('.question-text').value;
        const explanation = block.querySelector('.question-explanation').value;
        const optionInputs = block.querySelectorAll('.option-input');
        const options = Array.from(optionInputs).map(input => input.value);
        const selectedRadio = block.querySelector('input[name="correctAnswer_' + index + '"]:checked');
        const answer = selectedRadio ? parseInt(selectedRadio.value) : 0;

        questions.push({
            question: questionText,
            explanation: explanation,
            options: options,
            answer: answer
        });
    });

    return questions;
}

// ================================
// UI Rendering
// ================================

function renderQuizzes(quizzes) {
    if (quizzes.length === 0) {
        quizzesList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">❓</div>
                <p>Aucun quiz pour le moment</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Ajoutez votre premier quiz ci-dessus</p>
            </div>
        `;
        return;
    }

    quizzesList.innerHTML = quizzes.map(quiz => {
        const questionsCount = quiz.questions ? quiz.questions.length : 0;
        return `
            <div class="conseil-item" data-id="${quiz.id}">
                <div class="conseil-content">
                    <h3 class="conseil-title">${escapeHtml(quiz.theme || 'Sans thème')}</h3>
                    <div class="conseil-meta">
                        ${quiz.themeColor ? '<span class="color-badge" style="background:' + quiz.themeColor + ';"></span>' : ''}
                        <span class="conseil-type">📝 ${questionsCount} question${questionsCount > 1 ? 's' : ''}</span>
                    </div>
                </div>
                <div class="conseil-actions">
                    <button class="btn btn-secondary" onclick="handleEdit('${quiz.id}')">✏️ Modifier</button>
                    <button class="btn btn-danger" onclick="handleDelete('${quiz.id}')">🗑️ Supprimer</button>
                </div>
            </div>
        `;
    }).join('');
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
    quizForm.reset();
    editingId = null;
    questionCount = 0;
    submitBtn.querySelector('.btn-text').textContent = 'Ajouter le quiz';
    submitBtn.classList.remove('editing');

    themeColorInput.value = '#1e3a5f';
    colorHexDisplay.textContent = '#1E3A5F';

    questionsContainer.innerHTML = '';
    addQuestion();
}

function populateForm(quiz) {
    document.getElementById('theme').value = quiz.theme || '';

    const color = quiz.themeColor || '#1e3a5f';
    themeColorInput.value = color;
    colorHexDisplay.textContent = color.toUpperCase();

    questionsContainer.innerHTML = '';
    questionCount = 0;

    if (quiz.questions && quiz.questions.length > 0) {
        quiz.questions.forEach(q => addQuestion(q));
    } else {
        addQuestion();
    }

    updateRemoveQuestionButtons();

    editingId = quiz.id;
    submitBtn.querySelector('.btn-text').textContent = '✏️ Modifier le quiz';
    submitBtn.classList.add('editing');

    quizForm.scrollIntoView({ behavior: 'smooth' });
}

// ================================
// Event Handlers
// ================================

addQuestionBtn.addEventListener('click', () => addQuestion());

quizForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoader = submitBtn.querySelector('.btn-loader');

    btnText.style.display = 'none';
    btnLoader.style.display = 'inline';
    submitBtn.disabled = true;

    try {
        const quizData = {
            theme: document.getElementById('theme').value,
            themeColor: themeColorInput.value.toUpperCase(),
            questions: getQuestionsFromForm()
        };

        if (editingId) {
            await updateQuiz(editingId, quizData);
        } else {
            await addQuiz(quizData);
        }

        resetForm();
        await loadQuizzes();
    } catch (error) {
        console.error('Form submission error:', error);
    } finally {
        btnText.style.display = 'inline';
        btnLoader.style.display = 'none';
        submitBtn.disabled = false;
    }
});

refreshBtn.addEventListener('click', loadQuizzes);

window.handleDelete = async function (id) {
    if (confirm('Êtes-vous sûr de vouloir supprimer ce quiz ?')) {
        await deleteQuiz(id);
        if (editingId === id) {
            resetForm();
        }
        await loadQuizzes();
    }
};

window.handleEdit = async function (id) {
    try {
        const quizzes = await getQuizzes();
        const quiz = quizzes.find(q => q.id === id);
        if (quiz) {
            populateForm(quiz);
        }
    } catch (error) {
        console.error('Error loading quiz for edit:', error);
    }
};

// ================================
// Initialization
// ================================

async function loadQuizzes() {
    quizzesList.innerHTML = `
        <div class="loading-state">
            <div class="spinner"></div>
            <p>Chargement des quiz...</p>
        </div>
    `;

    try {
        const quizzes = await getQuizzes();
        renderQuizzes(quizzes);
    } catch (error) {
        quizzesList.innerHTML = `
            <div class="empty-state">
                <div class="empty-state-icon">⚠️</div>
                <p>Erreur de connexion à Firebase</p>
                <p style="font-size: 0.85rem; margin-top: 0.5rem;">Vérifiez votre connexion internet</p>
            </div>
        `;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    addQuestion();
    loadQuizzes();
});

console.log('🚀 SIGH Admin - Quiz initialized (No Server Mode)');
