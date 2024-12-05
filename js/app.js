import { gun, numbers } from './db.js';

// Initialize current number
let currentNumber = 0;

// Update the display when the number changes
numbers.get('current').on(number => {
    if (number) {
        currentNumber = number;
        document.querySelector('.number').textContent = number;
    }
});

// Handle taking a new number
document.getElementById('take-number').addEventListener('click', () => {
    numbers.get('current').once(number => {
        const nextNumber = (parseInt(number) || 0) + 1;
        numbers.get('current').put(nextNumber);
    });
});