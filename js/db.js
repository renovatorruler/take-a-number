// Initialize GunDB
export const gun = Gun({
    peers: ['http://localhost:8765/gun'] // We'll set up a proper peer later
});

// Create a namespace for our number system
export const numbers = gun.get('take-a-number');