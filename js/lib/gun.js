// gun.js - GunDB connection and CRUD helpers

// Gun instance (singleton)
let gunInstance = null;

/**
 * Initialize Gun connection
 * @param {string[]} peers - Array of relay peer URLs
 * @returns {Gun} Gun instance
 */
function initGun(peers = ['https://gun-manhattan.herokuapp.com/gun']) {
  if (gunInstance) return gunInstance;
  
  // Check if Gun is available (browser vs Node)
  const GunConstructor = typeof Gun !== 'undefined' ? Gun : null;
  if (!GunConstructor) {
    throw new Error('Gun is not loaded. Include gun.js before using this module.');
  }
  
  gunInstance = GunConstructor(peers);
  return gunInstance;
}

/**
 * Get Gun instance (must call initGun first)
 * @returns {Gun} Gun instance
 */
function getGun() {
  if (!gunInstance) {
    throw new Error('Gun not initialized. Call initGun() first.');
  }
  return gunInstance;
}

/**
 * Reset Gun instance (for testing)
 */
function resetGun() {
  gunInstance = null;
}

/**
 * Generate a UUID
 * @returns {string} UUID string
 */
function generateId() {
  // Use crypto.randomUUID if available, fallback to manual generation
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  // Fallback for older browsers
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Create a new store
 * @param {string} name - Store name (required)
 * @param {object} options - Optional settings
 * @returns {Promise<{storeId: string, adminId: string, store: object}>}
 */
async function createStore(name, options = {}) {
  if (!name || typeof name !== 'string') {
    throw new Error('Store name is required');
  }
  
  const trimmedName = name.trim();
  if (trimmedName.length < 1 || trimmedName.length > 50) {
    throw new Error('Store name must be 1-50 characters');
  }
  
  // XSS sanitization - escape HTML entities
  const sanitizedName = trimmedName
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
  
  const gun = getGun();
  const storeId = generateId();
  const adminId = generateId();
  const timestamp = Date.now();
  
  const store = {
    id: storeId,
    name: sanitizedName,
    createdAt: timestamp,
    adminId: adminId,
    settings: {
      expiryHours: options.expiryHours || 24,
      expiryAfterServed: options.expiryAfterServed || 10
    },
    currentNumber: 0,
    nowServing: 0,
    servedToday: 0,
    servedLastHour: 0,
    version: '1.0'
  };
  
  return new Promise((resolve, reject) => {
    gun.get('stores').get(storeId).put(store, (ack) => {
      if (ack.err) {
        reject(new Error(ack.err));
      } else {
        resolve({ storeId, adminId, store });
      }
    });
  });
}

/**
 * Get store by ID
 * @param {string} storeId - Store ID
 * @returns {Promise<object|null>} Store data or null if not found
 */
function getStore(storeId) {
  if (!storeId) {
    return Promise.reject(new Error('Store ID is required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve) => {
    gun.get('stores').get(storeId).once((data) => {
      if (data && data.id) {
        resolve(data);
      } else {
        resolve(null);
      }
    });
  });
}

/**
 * Get store by admin ID
 * @param {string} adminId - Admin ID
 * @returns {Promise<object|null>} Store data or null if not found
 */
function getStoreByAdminId(adminId) {
  if (!adminId) {
    return Promise.reject(new Error('Admin ID is required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve) => {
    let found = false;
    gun.get('stores').map().once((store, key) => {
      if (!found && store && store.adminId === adminId) {
        found = true;
        resolve(store);
      }
    });
    // Give some time for stores to be scanned
    setTimeout(() => {
      if (!found) resolve(null);
    }, 2000);
  });
}

/**
 * Update store data
 * @param {string} storeId - Store ID
 * @param {object} updates - Fields to update
 * @returns {Promise<object>} Updated store data
 */
function updateStore(storeId, updates) {
  if (!storeId) {
    return Promise.reject(new Error('Store ID is required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve, reject) => {
    gun.get('stores').get(storeId).put(updates, (ack) => {
      if (ack.err) {
        reject(new Error(ack.err));
      } else {
        // Return the updated store
        getStore(storeId).then(resolve).catch(reject);
      }
    });
  });
}

/**
 * Subscribe to store updates
 * @param {string} storeId - Store ID
 * @param {function} callback - Called with store data on each update
 * @returns {function} Unsubscribe function
 */
function subscribeToStore(storeId, callback) {
  if (!storeId || typeof callback !== 'function') {
    throw new Error('Store ID and callback are required');
  }
  
  const gun = getGun();
  const ref = gun.get('stores').get(storeId);
  
  ref.on((data) => {
    if (data && data.id) {
      callback(data);
    }
  });
  
  // Return unsubscribe function
  return () => ref.off();
}

/**
 * Create a new ticket
 * @param {string} storeId - Store ID
 * @param {string} deviceId - Device ID (from localStorage keypair)
 * @returns {Promise<object>} Created ticket
 */
async function createTicket(storeId, deviceId) {
  if (!storeId || !deviceId) {
    throw new Error('Store ID and device ID are required');
  }
  
  const gun = getGun();
  
  // Get current store to determine next number
  const store = await getStore(storeId);
  if (!store) {
    throw new Error('Store not found');
  }
  
  const nextNumber = (store.currentNumber || 0) + 1;
  const timestamp = Date.now();
  
  const ticket = {
    number: nextNumber,
    deviceId: deviceId,
    issuedAt: timestamp,
    status: 'waiting',
    servedAt: null,
    servedBy: null
  };
  
  return new Promise((resolve, reject) => {
    // First update the store's current number
    gun.get('stores').get(storeId).put({ currentNumber: nextNumber }, (ack) => {
      if (ack.err) {
        reject(new Error(ack.err));
        return;
      }
      
      // Then create the ticket
      gun.get('stores').get(storeId).get('tickets').get(String(nextNumber)).put(ticket, (ack2) => {
        if (ack2.err) {
          reject(new Error(ack2.err));
        } else {
          resolve(ticket);
        }
      });
    });
  });
}

/**
 * Get a specific ticket
 * @param {string} storeId - Store ID
 * @param {number} ticketNumber - Ticket number
 * @returns {Promise<object|null>} Ticket data or null
 */
function getTicket(storeId, ticketNumber) {
  if (!storeId || ticketNumber === undefined) {
    return Promise.reject(new Error('Store ID and ticket number are required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve) => {
    gun.get('stores').get(storeId).get('tickets').get(String(ticketNumber)).once((data) => {
      if (data && data.number) {
        resolve(data);
      } else {
        resolve(null);
      }
    });
  });
}

/**
 * Get ticket by device ID
 * @param {string} storeId - Store ID
 * @param {string} deviceId - Device ID
 * @returns {Promise<object|null>} Ticket data or null
 */
function getTicketByDeviceId(storeId, deviceId) {
  if (!storeId || !deviceId) {
    return Promise.reject(new Error('Store ID and device ID are required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve) => {
    let found = false;
    gun.get('stores').get(storeId).get('tickets').map().once((ticket, key) => {
      if (!found && ticket && ticket.deviceId === deviceId && ticket.status === 'waiting') {
        found = true;
        resolve(ticket);
      }
    });
    // Give time for tickets to be scanned
    setTimeout(() => {
      if (!found) resolve(null);
    }, 2000);
  });
}

/**
 * Get all tickets for a store
 * @param {string} storeId - Store ID
 * @param {object} options - Filter options
 * @returns {Promise<object[]>} Array of tickets
 */
function getTickets(storeId, options = {}) {
  if (!storeId) {
    return Promise.reject(new Error('Store ID is required'));
  }
  
  const gun = getGun();
  const tickets = [];
  
  return new Promise((resolve) => {
    gun.get('stores').get(storeId).get('tickets').map().once((ticket, key) => {
      if (ticket && ticket.number) {
        // Apply filters
        if (options.status && ticket.status !== options.status) {
          return;
        }
        tickets.push(ticket);
      }
    });
    
    // Give time for all tickets to be collected
    setTimeout(() => {
      // Sort by number
      tickets.sort((a, b) => a.number - b.number);
      resolve(tickets);
    }, 500);
  });
}

/**
 * Update a ticket
 * @param {string} storeId - Store ID
 * @param {number} ticketNumber - Ticket number
 * @param {object} updates - Fields to update
 * @returns {Promise<object>} Updated ticket
 */
function updateTicket(storeId, ticketNumber, updates) {
  if (!storeId || ticketNumber === undefined) {
    return Promise.reject(new Error('Store ID and ticket number are required'));
  }
  
  const gun = getGun();
  
  return new Promise((resolve, reject) => {
    gun.get('stores').get(storeId).get('tickets').get(String(ticketNumber)).put(updates, (ack) => {
      if (ack.err) {
        reject(new Error(ack.err));
      } else {
        getTicket(storeId, ticketNumber).then(resolve).catch(reject);
      }
    });
  });
}

/**
 * Mark a ticket as served
 * @param {string} storeId - Store ID
 * @param {number} ticketNumber - Ticket number
 * @param {string} servedBy - 'self' or 'operator'
 * @returns {Promise<object>} Updated ticket
 */
async function markTicketServed(storeId, ticketNumber, servedBy = 'self') {
  const timestamp = Date.now();
  
  // Update ticket status
  const ticket = await updateTicket(storeId, ticketNumber, {
    status: 'served',
    servedAt: timestamp,
    servedBy: servedBy
  });
  
  // Update store stats and nowServing
  const store = await getStore(storeId);
  if (store) {
    const newNowServing = Math.max(store.nowServing || 0, ticketNumber);
    await updateStore(storeId, {
      nowServing: newNowServing,
      servedToday: (store.servedToday || 0) + 1,
      servedLastHour: (store.servedLastHour || 0) + 1
    });
  }
  
  return ticket;
}

/**
 * Subscribe to ticket updates for a store
 * @param {string} storeId - Store ID
 * @param {function} callback - Called with ticket data on each update
 * @returns {function} Unsubscribe function
 */
function subscribeToTickets(storeId, callback) {
  if (!storeId || typeof callback !== 'function') {
    throw new Error('Store ID and callback are required');
  }
  
  const gun = getGun();
  const ref = gun.get('stores').get(storeId).get('tickets');
  
  ref.map().on((ticket, key) => {
    if (ticket && ticket.number) {
      callback(ticket);
    }
  });
  
  // Return unsubscribe function
  return () => ref.map().off();
}

// Export for both browser and Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    initGun,
    getGun,
    resetGun,
    generateId,
    createStore,
    getStore,
    getStoreByAdminId,
    updateStore,
    subscribeToStore,
    createTicket,
    getTicket,
    getTicketByDeviceId,
    getTickets,
    updateTicket,
    markTicketServed,
    subscribeToTickets
  };
} else if (typeof window !== 'undefined') {
  window.GunHelpers = {
    initGun,
    getGun,
    resetGun,
    generateId,
    createStore,
    getStore,
    getStoreByAdminId,
    updateStore,
    subscribeToStore,
    createTicket,
    getTicket,
    getTicketByDeviceId,
    getTickets,
    updateTicket,
    markTicketServed,
    subscribeToTickets
  };
}
