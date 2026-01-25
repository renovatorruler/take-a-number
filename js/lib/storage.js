// storage.js - localStorage helpers

const KEYPAIR_KEY = 'tan_keypair';
const DEVICE_ID_KEY = 'tan_device_id';
const TICKET_PREFIX = 'tan_ticket_';

/**
 * Check if localStorage is available
 * @returns {boolean}
 */
function isStorageAvailable() {
  try {
    const test = '__storage_test__';
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Check if running in incognito/private mode
 * Incognito often has limited or no localStorage
 * @returns {boolean}
 */
function isIncognito() {
  if (!isStorageAvailable()) {
    return true;
  }
  
  // Additional checks for incognito
  try {
    // Safari incognito test
    if (typeof window !== 'undefined' && window.safari && window.safari.pushNotification) {
      return false;
    }
    
    // Chrome incognito has limited storage quota
    if (navigator && navigator.storage && navigator.storage.estimate) {
      // This is async but we check sync - for now just rely on localStorage test
    }
    
    // Firefox has unlimited storage in incognito but localStorage works
    // So if localStorage works, we assume not incognito
    return false;
  } catch (e) {
    return true;
  }
}

/**
 * Store keypair in localStorage
 * @param {object} keypair - SEA keypair object
 */
function storeKeypair(keypair) {
  if (!isStorageAvailable()) {
    throw new Error('localStorage is not available');
  }
  localStorage.setItem(KEYPAIR_KEY, JSON.stringify(keypair));
}

/**
 * Get keypair from localStorage
 * @returns {object|null} Keypair or null if not found
 */
function getKeypair() {
  if (!isStorageAvailable()) {
    return null;
  }
  const stored = localStorage.getItem(KEYPAIR_KEY);
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch (e) {
      return null;
    }
  }
  return null;
}

/**
 * Check if keypair exists
 * @returns {boolean}
 */
function hasKeypair() {
  return getKeypair() !== null;
}

/**
 * Clear keypair from storage
 */
function clearKeypair() {
  if (isStorageAvailable()) {
    localStorage.removeItem(KEYPAIR_KEY);
  }
}

/**
 * Store device ID
 * @param {string} deviceId
 */
function storeDeviceId(deviceId) {
  if (!isStorageAvailable()) {
    throw new Error('localStorage is not available');
  }
  localStorage.setItem(DEVICE_ID_KEY, deviceId);
}

/**
 * Get device ID
 * @returns {string|null}
 */
function getDeviceId() {
  if (!isStorageAvailable()) {
    return null;
  }
  return localStorage.getItem(DEVICE_ID_KEY);
}

/**
 * Store ticket for a store
 * @param {string} storeId
 * @param {object} ticket
 */
function storeTicket(storeId, ticket) {
  if (!isStorageAvailable()) {
    throw new Error('localStorage is not available');
  }
  localStorage.setItem(TICKET_PREFIX + storeId, JSON.stringify(ticket));
}

/**
 * Get ticket for a store
 * @param {string} storeId
 * @returns {object|null}
 */
function getTicket(storeId) {
  if (!isStorageAvailable()) {
    return null;
  }
  const stored = localStorage.getItem(TICKET_PREFIX + storeId);
  if (stored) {
    try {
      return JSON.parse(stored);
    } catch (e) {
      return null;
    }
  }
  return null;
}

/**
 * Check if ticket exists for a store
 * @param {string} storeId
 * @returns {boolean}
 */
function hasTicket(storeId) {
  return getTicket(storeId) !== null;
}

/**
 * Clear ticket for a store
 * @param {string} storeId
 */
function clearTicket(storeId) {
  if (isStorageAvailable()) {
    localStorage.removeItem(TICKET_PREFIX + storeId);
  }
}

/**
 * Clear all stored data
 */
function clearAll() {
  if (isStorageAvailable()) {
    // Clear known keys
    localStorage.removeItem(KEYPAIR_KEY);
    localStorage.removeItem(DEVICE_ID_KEY);
    
    // Clear all ticket keys
    const keys = Object.keys(localStorage);
    keys.forEach(key => {
      if (key.startsWith(TICKET_PREFIX)) {
        localStorage.removeItem(key);
      }
    });
  }
}

// Export for both browser and Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    isStorageAvailable,
    isIncognito,
    storeKeypair,
    getKeypair,
    hasKeypair,
    clearKeypair,
    storeDeviceId,
    getDeviceId,
    storeTicket,
    getTicket,
    hasTicket,
    clearTicket,
    clearAll
  };
} else if (typeof window !== 'undefined') {
  window.Storage = {
    isStorageAvailable,
    isIncognito,
    storeKeypair,
    getKeypair,
    hasKeypair,
    clearKeypair,
    storeDeviceId,
    getDeviceId,
    storeTicket,
    getTicket,
    hasTicket,
    clearTicket,
    clearAll
  };
}
