// pow.js - Proof-of-Work wrapper using GunDB SEA

// Import storage helpers (deferred to avoid circular dependency issues)
function getStorage() {
  if (typeof module !== 'undefined' && module.exports) {
    return require('./storage.js');
  } else if (typeof window !== 'undefined') {
    return window.Storage;
  }
  return null;
}

/**
 * Generate a new SEA keypair with proof-of-work
 * This takes ~2-3 seconds due to the computational work involved
 * @returns {Promise<object>} SEA keypair
 */
async function generateKeyPair() {
  // Check if SEA is available
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  const Storage = getStorage();
  
  // Check if we already have a keypair stored
  if (Storage && Storage.hasKeypair && Storage.hasKeypair()) {
    const existing = Storage.getKeypair();
    if (existing && existing.pub && existing.priv) {
      return existing;
    }
  }
  
  // Generate new keypair (this includes PoW)
  const keypair = await SEA.pair();
  
  if (!keypair || !keypair.pub) {
    throw new Error('Failed to generate keypair');
  }
  
  // Store keypair for future use
  if (Storage && Storage.storeKeypair) {
    Storage.storeKeypair(keypair);
  }
  
  // Also store device ID (hash of public key)
  const deviceId = await getDeviceIdInternal(keypair);
  if (Storage && Storage.storeDeviceId) {
    Storage.storeDeviceId(deviceId);
  }
  
  return keypair;
}

/**
 * Internal function to get device ID (avoids recursion)
 */
async function getDeviceIdInternal(keypair) {
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  const deviceId = await SEA.work(keypair.pub, null, null, { name: 'SHA-256' });
  return deviceId;
}

/**
 * Get or generate device ID
 * @param {object} keypair - Optional keypair (will be fetched/generated if not provided)
 * @returns {Promise<string>} Device ID (hash of public key)
 */
async function getDeviceId(keypair = null) {
  // Check if SEA is available
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  const Storage = getStorage();
  
  // Check stored device ID first
  if (Storage && Storage.getDeviceId) {
    const stored = Storage.getDeviceId();
    if (stored) return stored;
  }
  
  // Get or generate keypair
  let pair = keypair;
  if (!pair) {
    if (Storage && Storage.getKeypair) {
      pair = Storage.getKeypair();
    }
    if (!pair) {
      pair = await generateKeyPair();
    }
  }
  
  // Hash the public key to create device ID
  const deviceId = await SEA.work(pair.pub, null, null, { name: 'SHA-256' });
  
  return deviceId;
}

/**
 * Perform proof-of-work on some data
 * This is used to prevent spam (creates computational cost)
 * @param {any} data - Data to perform work on
 * @param {object} keypair - Optional keypair (will use stored if not provided)
 * @returns {Promise<string>} Work proof
 */
async function doProofOfWork(data, keypair = null) {
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  const Storage = getStorage();
  
  // Get keypair
  let pair = keypair;
  if (!pair) {
    if (Storage && Storage.getKeypair) {
      pair = Storage.getKeypair();
    }
    if (!pair) {
      pair = await generateKeyPair();
    }
  }
  
  // Perform work
  const work = await SEA.work(data, pair);
  
  if (!work) {
    throw new Error('Failed to perform proof of work');
  }
  
  return work;
}

/**
 * Verify proof-of-work
 * @param {any} data - Original data
 * @param {string} proof - Work proof to verify
 * @param {object} keypair - Keypair used for the work
 * @returns {Promise<boolean>} True if valid
 */
async function verifyWork(data, proof, keypair) {
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  if (!keypair || !keypair.pub) {
    throw new Error('Keypair is required for verification');
  }
  
  // Perform the same work and compare
  const expectedWork = await SEA.work(data, keypair);
  
  return proof === expectedWork;
}

/**
 * Sign data with keypair
 * @param {any} data - Data to sign
 * @param {object} keypair - Optional keypair
 * @returns {Promise<string>} Signed data
 */
async function signData(data, keypair = null) {
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  const Storage = getStorage();
  
  let pair = keypair;
  if (!pair) {
    if (Storage && Storage.getKeypair) {
      pair = Storage.getKeypair();
    }
    if (!pair) {
      throw new Error('No keypair available for signing');
    }
  }
  
  const signed = await SEA.sign(data, pair);
  
  if (!signed) {
    throw new Error('Failed to sign data');
  }
  
  return signed;
}

/**
 * Verify signed data
 * @param {string} signedData - Signed data string
 * @param {string} publicKey - Public key to verify with
 * @returns {Promise<any|false>} Original data if valid, false otherwise
 */
async function verifySignature(signedData, publicKey) {
  const SEA = typeof window !== 'undefined' ? window.SEA : global.SEA;
  if (!SEA) {
    throw new Error('GunDB SEA is not loaded');
  }
  
  const verified = await SEA.verify(signedData, publicKey);
  
  return verified;
}

/**
 * Check if keypair exists
 * @returns {boolean}
 */
function hasKeypair() {
  const Storage = getStorage();
  return Storage && Storage.hasKeypair && Storage.hasKeypair();
}

/**
 * Get stored keypair
 * @returns {object|null}
 */
function getStoredKeypair() {
  const Storage = getStorage();
  return Storage && Storage.getKeypair ? Storage.getKeypair() : null;
}

// Export for both browser and Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    generateKeyPair,
    getDeviceId,
    doProofOfWork,
    verifyWork,
    signData,
    verifySignature,
    hasKeypair,
    getStoredKeypair
  };
} else if (typeof window !== 'undefined') {
  window.PoW = {
    generateKeyPair,
    getDeviceId,
    doProofOfWork,
    verifyWork,
    signData,
    verifySignature,
    hasKeypair,
    getStoredKeypair
  };
}
