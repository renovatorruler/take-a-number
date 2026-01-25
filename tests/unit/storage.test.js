// storage.test.js - Unit tests for localStorage helpers
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// Mock localStorage
const localStorageMock = (() => {
  let store = {};
  return {
    getItem: vi.fn((key) => store[key] || null),
    setItem: vi.fn((key, value) => {
      store[key] = value.toString();
    }),
    removeItem: vi.fn((key) => {
      delete store[key];
    }),
    clear: vi.fn(() => {
      store = {};
    }),
    get length() {
      return Object.keys(store).length;
    },
    key: vi.fn((i) => Object.keys(store)[i] || null)
  };
})();

// Set up global localStorage mock
Object.defineProperty(global, 'localStorage', {
  value: localStorageMock,
  writable: true
});

// Import after mocking
const storageModule = await import('../../js/lib/storage.js');

describe('Storage Helpers', () => {
  beforeEach(() => {
    localStorageMock.clear();
    vi.clearAllMocks();
  });

  describe('isStorageAvailable', () => {
    it('should return true when localStorage works', () => {
      expect(storageModule.isStorageAvailable()).toBe(true);
    });

    it('should return false when localStorage throws', () => {
      const originalSetItem = localStorageMock.setItem;
      localStorageMock.setItem = vi.fn(() => {
        throw new Error('Storage full');
      });
      
      expect(storageModule.isStorageAvailable()).toBe(false);
      
      localStorageMock.setItem = originalSetItem;
    });
  });

  describe('isIncognito', () => {
    it('should return false when localStorage works', () => {
      expect(storageModule.isIncognito()).toBe(false);
    });
  });

  describe('keypair storage', () => {
    const testKeypair = {
      pub: 'test-public-key',
      priv: 'test-private-key',
      epub: 'test-epub',
      epriv: 'test-epriv'
    };

    it('should store and retrieve keypair', () => {
      storageModule.storeKeypair(testKeypair);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        'tan_keypair',
        JSON.stringify(testKeypair)
      );
      
      const retrieved = storageModule.getKeypair();
      expect(retrieved).toEqual(testKeypair);
    });

    it('should return null when no keypair stored', () => {
      expect(storageModule.getKeypair()).toBeNull();
    });

    it('should check if keypair exists', () => {
      expect(storageModule.hasKeypair()).toBe(false);
      
      storageModule.storeKeypair(testKeypair);
      
      expect(storageModule.hasKeypair()).toBe(true);
    });

    it('should clear keypair', () => {
      storageModule.storeKeypair(testKeypair);
      expect(storageModule.hasKeypair()).toBe(true);
      
      storageModule.clearKeypair();
      
      expect(storageModule.hasKeypair()).toBe(false);
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('tan_keypair');
    });

    it('should handle invalid JSON gracefully', () => {
      localStorageMock.getItem = vi.fn(() => 'not-valid-json');
      
      expect(storageModule.getKeypair()).toBeNull();
    });
  });

  describe('device ID storage', () => {
    it('should store and retrieve device ID', () => {
      storageModule.storeDeviceId('test-device-id');
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        'tan_device_id',
        'test-device-id'
      );
    });

    it('should return null when no device ID stored', () => {
      localStorageMock.getItem = vi.fn(() => null);
      expect(storageModule.getDeviceId()).toBeNull();
    });
  });

  describe('ticket storage', () => {
    const testTicket = {
      number: 42,
      deviceId: 'device-123',
      status: 'waiting',
      issuedAt: 1234567890
    };
    const storeId = 'store-abc';

    it('should store and retrieve ticket', () => {
      storageModule.storeTicket(storeId, testTicket);
      
      expect(localStorageMock.setItem).toHaveBeenCalledWith(
        'tan_ticket_store-abc',
        JSON.stringify(testTicket)
      );
      
      // Update mock to return stored ticket
      localStorageMock.getItem = vi.fn((key) => {
        if (key === 'tan_ticket_store-abc') return JSON.stringify(testTicket);
        return null;
      });
      
      const retrieved = storageModule.getTicket(storeId);
      expect(retrieved).toEqual(testTicket);
    });

    it('should return null when no ticket stored', () => {
      localStorageMock.getItem = vi.fn(() => null);
      expect(storageModule.getTicket(storeId)).toBeNull();
    });

    it('should check if ticket exists', () => {
      localStorageMock.getItem = vi.fn(() => null);
      expect(storageModule.hasTicket(storeId)).toBe(false);
      
      storageModule.storeTicket(storeId, testTicket);
      localStorageMock.getItem = vi.fn(() => JSON.stringify(testTicket));
      
      expect(storageModule.hasTicket(storeId)).toBe(true);
    });

    it('should clear ticket', () => {
      storageModule.storeTicket(storeId, testTicket);
      
      storageModule.clearTicket(storeId);
      
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('tan_ticket_store-abc');
    });

    it('should handle invalid JSON gracefully', () => {
      localStorageMock.getItem = vi.fn(() => 'not-valid-json');
      
      expect(storageModule.getTicket(storeId)).toBeNull();
    });
  });

  describe('clearAll', () => {
    it('should clear all stored data', () => {
      // Store some data
      storageModule.storeKeypair({ pub: 'key' });
      storageModule.storeDeviceId('device');
      storageModule.storeTicket('store1', { number: 1 });
      storageModule.storeTicket('store2', { number: 2 });
      
      // Mock Object.keys to return our keys
      Object.keys = vi.fn(() => ['tan_keypair', 'tan_device_id', 'tan_ticket_store1', 'tan_ticket_store2']);
      
      storageModule.clearAll();
      
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('tan_keypair');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('tan_device_id');
    });
  });
});
