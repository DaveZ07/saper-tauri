class Saper {
    constructor() {
        console.log('Konstruktor Saper wywołany');
        this.difficulties = {
            easy: { rows: 9, cols: 9, mines: 10 },
            medium: { rows: 16, cols: 16, mines: 40 },
            hard: { rows: 30, cols: 16, mines: 99 }
        };
        
        this.currentDifficulty = 'easy';
        this.board = [];
        this.gameBoard = document.getElementById('game-board');
        this.minesCount = document.getElementById('mines-count');
        this.timer = document.getElementById('timer');
        this.newGameBtn = document.getElementById('new-game');
        
        console.log('Elementy DOM:', {
            gameBoard: this.gameBoard,
            minesCount: this.minesCount,
            timer: this.timer,
            newGameBtn: this.newGameBtn
        });
        
        this.gameStarted = false;
        this.gameEnded = false;
        this.startTime = null;
        this.timerInterval = null;
        this.flagsUsed = 0;
        
        this.init();
    }
    
    showModal(icon, title, message) {
        const modal = document.getElementById('game-modal');
        const modalIcon = modal.querySelector('.modal-icon');
        const modalTitle = modal.querySelector('.modal-title');
        const modalMessage = modal.querySelector('.modal-message');
        const modalBtn = modal.querySelector('#modal-ok');
        
        modalIcon.textContent = icon;
        modalTitle.textContent = title;
        modalMessage.textContent = message;
        
        modal.style.display = 'flex';
        
        // Obsługa zamknięcia modala
        const closeModal = () => {
            modal.style.display = 'none';
            modalBtn.removeEventListener('click', closeModal);
            modal.removeEventListener('click', overlayClose);
        };
        
        const overlayClose = (e) => {
            if (e.target === modal) {
                closeModal();
            }
        };
        
        modalBtn.addEventListener('click', closeModal);
        modal.addEventListener('click', overlayClose);
    }
    
    getCellSize() {
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;
        const config = this.difficulties[this.currentDifficulty];
        
        // Oblicz maksymalny rozmiar komórki jaki się zmieści
        const maxWidth = Math.floor((screenWidth - 100) / config.cols);
        const maxHeight = Math.floor((screenHeight - 300) / config.rows);
        
        let cellSize = Math.min(maxWidth, maxHeight);
        
        // Minimalne i maksymalne rozmiary
        cellSize = Math.max(cellSize, 25); // minimum 25px
        cellSize = Math.min(cellSize, 50); // maksimum 50px
        
        return cellSize;
    }
    
    init() {
        this.setupEventListeners();
        this.createBoard();
    }
    
    setupEventListeners() {
        this.newGameBtn.addEventListener('click', () => this.newGame());
        
        document.querySelectorAll('.difficulty-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                document.querySelectorAll('.difficulty-btn').forEach(b => b.classList.remove('active'));
                e.target.classList.add('active');
                this.currentDifficulty = e.target.dataset.level;
                this.newGame();
            });
        });
        
        // Obsługa zmiany rozmiaru okna i orientacji
        window.addEventListener('resize', () => {
            this.adjustBoardSize();
        });
        
        window.addEventListener('orientationchange', () => {
            setTimeout(() => {
                this.adjustBoardSize();
            }, 100);
        });
        
        // Oznacz pierwszy poziom jako aktywny
        document.querySelector('.difficulty-btn[data-level="easy"]').classList.add('active');
    }
    
    adjustBoardSize() {
        if (this.gameBoard && this.board.length > 0) {
            const config = this.difficulties[this.currentDifficulty];
            const cellSize = this.getCellSize();
//            this.gameBoard.style.width = `${config.cols * cellSize}px`;
            
            // Odśwież rozmiary wszystkich komórek
            const cells = this.gameBoard.querySelectorAll('.cell');
            cells.forEach(cell => {
                cell.style.width = `${cellSize - 2}px`;
                cell.style.height = `${cellSize - 2}px`;
                cell.style.lineHeight = `${cellSize - 6}px`;
            });
            
            // Odśwież wysokości wierszy
            const rows = this.gameBoard.querySelectorAll('.row');
            rows.forEach(row => {
                row.style.height = `${cellSize}px`;
            });
        }
    }
    
    createBoard() {
        console.log('createBoard wywołana');
        const config = this.difficulties[this.currentDifficulty];
        console.log('Konfiguracja:', config);
        this.board = [];
        this.gameBoard.innerHTML = '';
        
        // Dynamicznie ustaw szerokość planszy na podstawie rozmiaru ekranu
        const cellSize = this.getCellSize();
        //this.gameBoard.style.width = `${config.cols * cellSize}px`;
        
        console.log('Tworzenie planszy...');
        
        // Utwórz pustą planszę
        for (let row = 0; row < config.rows; row++) {
            this.board[row] = [];
            const rowDiv = document.createElement('div');
            rowDiv.className = 'row';
            rowDiv.style.height = `${cellSize}px`;
            
            for (let col = 0; col < config.cols; col++) {
                const cell = document.createElement('div');
                cell.className = 'cell';
                cell.dataset.row = row;
                cell.dataset.col = col;
                
                // Ustaw rozmiary komórki bezpośrednio w stylu
                const actualCellSize = cellSize - 2; // odejmij margin/border
                cell.style.width = `${actualCellSize}px`;
                cell.style.height = `${actualCellSize}px`;
                cell.style.lineHeight = `${actualCellSize - 4}px`;
                
                cell.addEventListener('click', (e) => this.handleCellClick(e));
                cell.addEventListener('contextmenu', (e) => this.handleRightClick(e));
                
                rowDiv.appendChild(cell);
                
                this.board[row][col] = {
                    isMine: false,
                    isRevealed: false,
                    isFlagged: false,
                    neighborMines: 0,
                    element: cell
                };
            }
            this.gameBoard.appendChild(rowDiv);
        }
        
        this.placeMines();
        this.calculateNumbers();
        this.updateMinesDisplay();
        this.resetTimer();
    }
    
    placeMines() {
        const config = this.difficulties[this.currentDifficulty];
        let minesPlaced = 0;
        
        while (minesPlaced < config.mines) {
            const row = Math.floor(Math.random() * config.rows);
            const col = Math.floor(Math.random() * config.cols);
            
            if (!this.board[row][col].isMine) {
                this.board[row][col].isMine = true;
                minesPlaced++;
            }
        }
    }
    
    calculateNumbers() {
        const config = this.difficulties[this.currentDifficulty];
        
        for (let row = 0; row < config.rows; row++) {
            for (let col = 0; col < config.cols; col++) {
                if (!this.board[row][col].isMine) {
                    this.board[row][col].neighborMines = this.countNeighborMines(row, col);
                }
            }
        }
    }
    
    countNeighborMines(row, col) {
        let count = 0;
        for (let i = -1; i <= 1; i++) {
            for (let j = -1; j <= 1; j++) {
                const newRow = row + i;
                const newCol = col + j;
                if (this.isValidCell(newRow, newCol) && this.board[newRow][newCol].isMine) {
                    count++;
                }
            }
        }
        return count;
    }
    
    isValidCell(row, col) {
        const config = this.difficulties[this.currentDifficulty];
        return row >= 0 && row < config.rows && col >= 0 && col < config.cols;
    }
    
    handleCellClick(e) {
        if (this.gameEnded) return;
        
        const row = parseInt(e.target.dataset.row);
        const col = parseInt(e.target.dataset.col);
        const cell = this.board[row][col];
        
        if (cell.isFlagged || cell.isRevealed) return;
        
        if (!this.gameStarted) {
            this.startGame();
        }
        
        this.revealCell(row, col);
        this.checkWinCondition();
    }
    
    handleRightClick(e) {
        e.preventDefault();
        if (this.gameEnded) return;
        
        const row = parseInt(e.target.dataset.row);
        const col = parseInt(e.target.dataset.col);
        const cell = this.board[row][col];
        
        if (cell.isRevealed) return;
        
        this.toggleFlag(row, col);
    }
    
    toggleFlag(row, col) {
        const cell = this.board[row][col];
        
        if (cell.isFlagged) {
            cell.isFlagged = false;
            cell.element.classList.remove('flagged');
            this.flagsUsed--;
        } else {
            cell.isFlagged = true;
            cell.element.classList.add('flagged');
            this.flagsUsed++;
        }
        
        this.updateMinesDisplay();
    }
    
    revealCell(row, col) {
        const cell = this.board[row][col];
        
        if (cell.isRevealed || cell.isFlagged) return;
        
        cell.isRevealed = true;
        cell.element.classList.add('revealed');
        
        if (cell.isMine) {
            this.gameOver();
            return;
        }
        
        if (cell.neighborMines > 0) {
            cell.element.textContent = cell.neighborMines;
            cell.element.dataset.count = cell.neighborMines;
        } else {
            // Odkryj wszystkie sąsiednie puste pola
            for (let i = -1; i <= 1; i++) {
                for (let j = -1; j <= 1; j++) {
                    const newRow = row + i;
                    const newCol = col + j;
                    if (this.isValidCell(newRow, newCol)) {
                        this.revealCell(newRow, newCol);
                    }
                }
            }
        }
    }
    
    startGame() {
        this.gameStarted = true;
        this.startTime = Date.now();
        this.timerInterval = setInterval(() => {
            const elapsed = Math.floor((Date.now() - this.startTime) / 1000);
            this.timer.textContent = elapsed;
        }, 1000);
    }
    
    gameOver() {
        this.gameEnded = true;
        clearInterval(this.timerInterval);
        
        // Pokaż wszystkie miny
        for (let row = 0; row < this.board.length; row++) {
            for (let col = 0; col < this.board[row].length; col++) {
                if (this.board[row][col].isMine) {
                    this.board[row][col].element.classList.add('mine');
                }
            }
        }
        
        setTimeout(() => {
            this.showModal('💣', 'Gra zakończona!', 'Ups! Natrafiłeś na minę. Spróbuj ponownie!');
        }, 100);
    }
    
    checkWinCondition() {
        const config = this.difficulties[this.currentDifficulty];
        let revealedCells = 0;
        
        for (let row = 0; row < config.rows; row++) {
            for (let col = 0; col < config.cols; col++) {
                if (this.board[row][col].isRevealed && !this.board[row][col].isMine) {
                    revealedCells++;
                }
            }
        }
        
        if (revealedCells === (config.rows * config.cols) - config.mines) {
            this.winGame();
        }
    }
    
    winGame() {
        this.gameEnded = true;
        clearInterval(this.timerInterval);
        
        setTimeout(() => {
            const elapsed = Math.floor((Date.now() - this.startTime) / 1000);
            this.showModal('🏆', 'Gratulacje!', `Wygrałeś! Twój czas: ${elapsed} sekund`);
        }, 100);
    }
    
    newGame() {
        this.gameStarted = false;
        this.gameEnded = false;
        this.flagsUsed = 0;
        clearInterval(this.timerInterval);
        this.createBoard();
    }
    
    updateMinesDisplay() {
        const config = this.difficulties[this.currentDifficulty];
        this.minesCount.textContent = config.mines - this.flagsUsed;
    }
    
    resetTimer() {
        this.timer.textContent = '0';
    }
}

// Inicjalizuj grę po załadowaniu strony
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM załadowany, inicjalizuję grę...');
    try {
        const game = new Saper();
        console.log('Gra zainicjalizowana pomyślnie');
    } catch (error) {
        console.error('Błąd podczas inicjalizacji gry:', error);
    }
});

// Rejestracja Service Worker dla PWA
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then((registration) => {
                console.log('SW zarejestrowany: ', registration);
            })
            .catch((registrationError) => {
                console.log('SW rejestracja nieudana: ', registrationError);
            });
    });
}