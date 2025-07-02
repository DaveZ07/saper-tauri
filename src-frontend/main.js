class Saper {
    constructor() {
        this.difficulties = {
            easy: { rows: 9, cols: 9, mines: 10 },
            medium: { rows: 16, cols: 16, mines: 40 },
            hard: { rows: 16, cols: 30, mines: 99 }
        };
        
        this.currentDifficulty = 'easy';
        this.board = [];
        this.gameBoard = document.getElementById('game-board');
        this.minesCount = document.getElementById('mines-count');
        this.timer = document.getElementById('timer');
        this.newGameBtn = document.getElementById('new-game');
        
        this.gameStarted = false;
        this.gameEnded = false;
        this.startTime = null;
        this.timerInterval = null;
        this.flagsUsed = 0;
        
        this.init();
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
        
        // Oznacz pierwszy poziom jako aktywny
        document.querySelector('.difficulty-btn[data-level="easy"]').classList.add('active');
    }
    
    createBoard() {
        const config = this.difficulties[this.currentDifficulty];
        this.board = [];
        this.gameBoard.innerHTML = '';
        this.gameBoard.style.width = `${config.cols * 30}px`;
        
        // Utwórz pustą planszę
        for (let row = 0; row < config.rows; row++) {
            this.board[row] = [];
            const rowDiv = document.createElement('div');
            rowDiv.className = 'row';
            
            for (let col = 0; col < config.cols; col++) {
                const cell = document.createElement('div');
                cell.className = 'cell';
                cell.dataset.row = row;
                cell.dataset.col = col;
                
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
            alert('Gra skończona! Natrafiłeś na minę!');
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
            alert('Gratulacje! Wygrałeś!');
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
    new Saper();
});