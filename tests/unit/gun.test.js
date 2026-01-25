// gun.test.js - Unit tests for GunDB helpers
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';

// Mock Gun before importing the module
const mockPut = vi.fn((data, cb) => cb && cb({}));
const mockOnce = vi.fn((cb) => cb && cb(null));
const mockOn = vi.fn((cb) => cb);
const mockOff = vi.fn();
const mockMap = vi.fn(() => ({
  once: mockOnce,
  on: mockOn,
  off: mockOff
}));
const mockGet = vi.fn(() => ({
  get: mockGet,
  put: mockPut,
  once: mockOnce,
  on: mockOn,
  off: mockOff,
  map: mockMap
}));

const MockGun = vi.fn(() => ({
  get: mockGet
}));

// Set up global Gun mock
global.Gun = MockGun;

// Now import the module
const gunModule = await import('../../lib/es6/src/lib/GunHelpers.js');

describe('GunDB Helpers', () => {
  beforeEach(() => {
    // Reset all mocks before each test
    vi.clearAllMocks();
    gunModule.resetGun();
  });

  afterEach(() => {
    gunModule.resetGun();
  });

  describe('initGun', () => {
    it('should initialize Gun with default peers', () => {
      const gun = gunModule.initGun();
      expect(MockGun).toHaveBeenCalledWith(['https://gun-manhattan.herokuapp.com/gun']);
      expect(gun).toBeDefined();
    });

    it('should initialize Gun with custom peers', () => {
      const customPeers = ['https://custom-relay.com/gun'];
      gunModule.initGun(customPeers);
      expect(MockGun).toHaveBeenCalledWith(customPeers);
    });

    it('should return same instance on multiple calls', () => {
      const gun1 = gunModule.initGun();
      const gun2 = gunModule.initGun();
      expect(gun1).toBe(gun2);
    });
  });

  describe('getGun', () => {
    it('should throw if Gun not initialized', () => {
      expect(() => gunModule.getGun()).toThrow('Gun not initialized');
    });

    it('should return Gun instance after init', () => {
      gunModule.initGun();
      const gun = gunModule.getGun();
      expect(gun).toBeDefined();
    });
  });

  describe('generateId', () => {
    it('should generate a UUID string', () => {
      const id = gunModule.generateId();
      expect(typeof id).toBe('string');
      expect(id.length).toBeGreaterThan(0);
    });

    it('should generate unique IDs', () => {
      const id1 = gunModule.generateId();
      const id2 = gunModule.generateId();
      expect(id1).not.toBe(id2);
    });
  });

  describe('createStore', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should throw if name is not provided', async () => {
      await expect(gunModule.createStore()).rejects.toThrow('Store name is required');
      await expect(gunModule.createStore('')).rejects.toThrow('Store name is required');
    });

    it('should throw if name is too long', async () => {
      const longName = 'a'.repeat(51);
      await expect(gunModule.createStore(longName)).rejects.toThrow('Store name must be 1-50 characters');
    });

    it('should create store with valid name', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      
      const result = await gunModule.createStore('Test Store');
      
      expect(result).toHaveProperty('storeId');
      expect(result).toHaveProperty('adminId');
      expect(result).toHaveProperty('store');
      expect(result.store.name).toBe('Test Store');
      expect(result.store.currentNumber).toBe(0);
      expect(result.store.nowServing).toBe(0);
    });

    it('should sanitize store name for XSS', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      
      const result = await gunModule.createStore('<script>alert("xss")</script>');
      
      expect(result.store.name).not.toContain('<script>');
      expect(result.store.name).toContain('&lt;script&gt;');
    });

    it('should trim whitespace from store name', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      
      const result = await gunModule.createStore('  Test Store  ');
      
      expect(result.store.name).toBe('Test Store');
    });

    it('should reject on Gun error', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({ err: 'Gun error' }));
      
      await expect(gunModule.createStore('Test')).rejects.toThrow('Gun error');
    });
  });

  describe('getStore', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should reject if storeId is not provided', async () => {
      await expect(gunModule.getStore()).rejects.toThrow('Store ID is required');
    });

    it('should return null for non-existent store', async () => {
      mockOnce.mockImplementation((cb) => cb(null));
      
      const result = await gunModule.getStore('non-existent');
      
      expect(result).toBeFalsy();
    });

    it('should return store data if found', async () => {
      const mockStore = { id: 'test-id', name: 'Test Store' };
      mockOnce.mockImplementation((cb) => cb(mockStore));
      
      const result = await gunModule.getStore('test-id');
      
      expect(result).toEqual(mockStore);
    });
  });

  describe('updateStore', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should reject if storeId is not provided', async () => {
      await expect(gunModule.updateStore()).rejects.toThrow('Store ID is required');
    });

    it('should update store data', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      const mockStore = { id: 'test-id', name: 'Test Store', nowServing: 5 };
      mockOnce.mockImplementation((cb) => cb(mockStore));
      
      const result = await gunModule.updateStore('test-id', { nowServing: 5 });
      
      expect(mockPut).toHaveBeenCalledWith({ nowServing: 5 }, expect.any(Function));
      expect(result.nowServing).toBe(5);
    });
  });

  describe('subscribeToStore', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should throw if storeId is not provided', () => {
      expect(() => gunModule.subscribeToStore()).toThrow('Store ID and callback are required');
    });

    it('should throw if callback is not a function', () => {
      expect(() => gunModule.subscribeToStore('test-id', 'not-a-function')).toThrow('Store ID and callback are required');
    });

    it('should return unsubscribe function', () => {
      const callback = vi.fn();
      const unsubscribe = gunModule.subscribeToStore('test-id', callback);
      
      expect(typeof unsubscribe).toBe('function');
    });
  });

  describe('createTicket', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should throw if storeId or deviceId not provided', async () => {
      await expect(gunModule.createTicket()).rejects.toThrow('Store ID and device ID are required');
      await expect(gunModule.createTicket('store-id')).rejects.toThrow('Store ID and device ID are required');
    });

    it('should throw if store not found', async () => {
      mockOnce.mockImplementation((cb) => cb(null));
      
      await expect(gunModule.createTicket('non-existent', 'device-id')).rejects.toThrow('Store not found');
    });

    it('should create ticket with next number', async () => {
      const mockStore = { id: 'store-id', name: 'Test', currentNumber: 5 };
      mockOnce.mockImplementation((cb) => cb(mockStore));
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      
      const result = await gunModule.createTicket('store-id', 'device-id');
      
      expect(result.number).toBe(6);
      expect(result.deviceId).toBe('device-id');
      expect(result.status).toBe('waiting');
    });
  });

  describe('getTicket', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should reject if storeId or ticketNumber not provided', async () => {
      await expect(gunModule.getTicket()).rejects.toThrow('Store ID and ticket number are required');
    });

    it('should return null for non-existent ticket', async () => {
      mockOnce.mockImplementation((cb) => cb(null));
      
      const result = await gunModule.getTicket('store-id', 999);
      
      expect(result).toBeFalsy();
    });

    it('should return ticket data if found', async () => {
      const mockTicket = { number: 5, deviceId: 'device-id', status: 'waiting' };
      mockOnce.mockImplementation((cb) => cb(mockTicket));
      
      const result = await gunModule.getTicket('store-id', 5);
      
      expect(result).toEqual(mockTicket);
    });
  });

  describe('getTickets', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should reject if storeId not provided', async () => {
      await expect(gunModule.getTickets()).rejects.toThrow('Store ID is required');
    });

    it('should return empty array if no tickets', async () => {
      mockOnce.mockImplementation((cb) => {}); // No callback with data
      
      const result = await gunModule.getTickets('store-id');
      
      expect(result).toEqual([]);
    });
  });

  describe('updateTicket', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should reject if storeId or ticketNumber not provided', async () => {
      await expect(gunModule.updateTicket()).rejects.toThrow('Store ID and ticket number are required');
    });

    it('should update ticket data', async () => {
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      const mockTicket = { number: 5, status: 'served' };
      mockOnce.mockImplementation((cb) => cb(mockTicket));
      
      const result = await gunModule.updateTicket('store-id', 5, { status: 'served' });
      
      expect(mockPut).toHaveBeenCalledWith({ status: 'served' }, expect.any(Function));
    });
  });

  describe('markTicketServed', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should mark ticket as served and update store stats', async () => {
      const mockStore = { id: 'store-id', nowServing: 3, servedToday: 10, servedLastHour: 2 };
      const mockTicket = { number: 5, status: 'served', servedAt: expect.any(Number), servedBy: 'self' };
      
      mockPut.mockImplementation((data, cb) => cb && cb({}));
      mockOnce.mockImplementation((cb) => {
        // Return different data based on what's being queried
        cb(mockStore);
      });
      
      const result = await gunModule.markTicketServed('store-id', 5, 'self');
      
      // Verify put was called for both ticket and store update
      expect(mockPut).toHaveBeenCalled();
    });
  });

  describe('subscribeToTickets', () => {
    beforeEach(() => {
      gunModule.initGun();
    });

    it('should throw if storeId or callback not provided', () => {
      expect(() => gunModule.subscribeToTickets()).toThrow('Store ID and callback are required');
      expect(() => gunModule.subscribeToTickets('store-id')).toThrow('Store ID and callback are required');
    });

    it('should return unsubscribe function', () => {
      const callback = vi.fn();
      const unsubscribe = gunModule.subscribeToTickets('store-id', callback);
      
      expect(typeof unsubscribe).toBe('function');
    });
  });
});
