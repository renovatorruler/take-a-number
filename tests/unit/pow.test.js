// pow.test.js - Unit tests for Proof-of-Work wrapper
import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock SEA
const mockKeypair = {
  pub: 'mock-public-key',
  priv: 'mock-private-key',
  epub: 'mock-epub',
  epriv: 'mock-epriv'
};

const mockSEA = {
  pair: vi.fn(async () => mockKeypair),
  work: vi.fn(async (data, pair) => 'mock-work-proof'),
  sign: vi.fn(async (data, pair) => 'signed:' + JSON.stringify(data)),
  verify: vi.fn(async (signed, pub) => {
    if (typeof signed === 'string' && signed.startsWith('signed:')) {
      return JSON.parse(signed.slice(7));
    }
    return false;
  })
};

// Set up global mocks
global.SEA = mockSEA;

beforeEach(() => {
  vi.clearAllMocks();
});

// Import modules
const powModule = await import('../../js/lib/pow.js');

describe('PoW Wrapper', () => {
  describe('generateKeyPair', () => {
    it('should generate a new keypair using SEA.pair()', async () => {
      const keypair = await powModule.generateKeyPair();
      
      expect(mockSEA.pair).toHaveBeenCalled();
      expect(keypair).toEqual(mockKeypair);
    });

    it('should compute device ID using SEA.work()', async () => {
      await powModule.generateKeyPair();
      
      // SEA.work is called to compute the device ID from the public key
      expect(mockSEA.work).toHaveBeenCalledWith(
        mockKeypair.pub,
        null,
        null,
        { name: 'SHA-256' }
      );
    });
  });

  describe('doProofOfWork', () => {
    it('should perform proof of work on data with provided keypair', async () => {
      const data = { action: 'create-store', timestamp: Date.now() };
      const proof = await powModule.doProofOfWork(data, mockKeypair);
      
      expect(mockSEA.work).toHaveBeenCalledWith(data, mockKeypair);
      expect(proof).toBe('mock-work-proof');
    });

    it('should work with string data', async () => {
      const data = 'test-data';
      const proof = await powModule.doProofOfWork(data, mockKeypair);
      
      expect(mockSEA.work).toHaveBeenCalledWith(data, mockKeypair);
      expect(proof).toBe('mock-work-proof');
    });

    it('should work with object data', async () => {
      const data = { foo: 'bar', num: 123 };
      const proof = await powModule.doProofOfWork(data, mockKeypair);
      
      expect(mockSEA.work).toHaveBeenCalledWith(data, mockKeypair);
      expect(proof).toBe('mock-work-proof');
    });

    it('should throw if work fails', async () => {
      mockSEA.work.mockResolvedValueOnce(null);
      
      await expect(powModule.doProofOfWork('data', mockKeypair))
        .rejects.toThrow('Failed to perform proof of work');
    });
  });

  describe('verifyWork', () => {
    it('should return true when proof matches', async () => {
      const data = 'test-data';
      
      const isValid = await powModule.verifyWork(data, 'mock-work-proof', mockKeypair);
      
      expect(mockSEA.work).toHaveBeenCalledWith(data, mockKeypair);
      expect(isValid).toBe(true);
    });

    it('should return false when proof does not match', async () => {
      const data = 'test-data';
      
      const isValid = await powModule.verifyWork(data, 'wrong-proof', mockKeypair);
      
      expect(isValid).toBe(false);
    });

    it('should throw if keypair is null', async () => {
      await expect(powModule.verifyWork('data', 'proof', null))
        .rejects.toThrow('Keypair is required');
    });

    it('should throw if keypair has no public key', async () => {
      await expect(powModule.verifyWork('data', 'proof', { priv: 'only-priv' }))
        .rejects.toThrow('Keypair is required');
    });

    it('should throw if keypair is undefined', async () => {
      await expect(powModule.verifyWork('data', 'proof', undefined))
        .rejects.toThrow('Keypair is required');
    });
  });

  describe('signData', () => {
    it('should sign data with provided keypair', async () => {
      const data = { message: 'hello' };
      const signed = await powModule.signData(data, mockKeypair);
      
      expect(mockSEA.sign).toHaveBeenCalledWith(data, mockKeypair);
      expect(signed).toBe('signed:{"message":"hello"}');
    });

    it('should sign string data', async () => {
      const data = 'test-string';
      const signed = await powModule.signData(data, mockKeypair);
      
      expect(mockSEA.sign).toHaveBeenCalledWith(data, mockKeypair);
      expect(signed).toContain('signed:');
    });

    it('should throw if signing fails', async () => {
      mockSEA.sign.mockResolvedValueOnce(null);
      
      await expect(powModule.signData('data', mockKeypair))
        .rejects.toThrow('Failed to sign data');
    });
  });

  describe('verifySignature', () => {
    it('should verify and return original data for valid signature', async () => {
      const signedData = 'signed:{"message":"hello"}';
      const publicKey = 'test-pub-key';
      
      const result = await powModule.verifySignature(signedData, publicKey);
      
      expect(mockSEA.verify).toHaveBeenCalledWith(signedData, publicKey);
      expect(result).toEqual({ message: 'hello' });
    });

    it('should return false for invalid signature', async () => {
      mockSEA.verify.mockResolvedValueOnce(false);
      
      const result = await powModule.verifySignature('invalid-signature', 'pub-key');
      
      expect(result).toBe(false);
    });

    it('should pass public key correctly', async () => {
      const publicKey = 'specific-public-key';
      await powModule.verifySignature('signed:{}', publicKey);
      
      expect(mockSEA.verify).toHaveBeenCalledWith('signed:{}', publicKey);
    });
  });

  describe('getDeviceId', () => {
    it('should compute device ID from keypair public key', async () => {
      const deviceId = await powModule.getDeviceId(mockKeypair);
      
      expect(mockSEA.work).toHaveBeenCalledWith(
        mockKeypair.pub,
        null,
        null,
        { name: 'SHA-256' }
      );
      expect(deviceId).toBe('mock-work-proof');
    });

    it('should generate keypair if none provided', async () => {
      // Clear any stored state first by calling without args
      mockSEA.pair.mockClear();
      
      // This will trigger keypair generation since no keypair is provided
      await powModule.getDeviceId();
      
      // Should have generated a keypair
      expect(mockSEA.pair).toHaveBeenCalled();
    });
  });

  describe('module exports', () => {
    it('should export generateKeyPair', () => {
      expect(typeof powModule.generateKeyPair).toBe('function');
    });

    it('should export getDeviceId', () => {
      expect(typeof powModule.getDeviceId).toBe('function');
    });

    it('should export doProofOfWork', () => {
      expect(typeof powModule.doProofOfWork).toBe('function');
    });

    it('should export verifyWork', () => {
      expect(typeof powModule.verifyWork).toBe('function');
    });

    it('should export signData', () => {
      expect(typeof powModule.signData).toBe('function');
    });

    it('should export verifySignature', () => {
      expect(typeof powModule.verifySignature).toBe('function');
    });

    it('should export hasKeypair', () => {
      expect(typeof powModule.hasKeypair).toBe('function');
    });

    it('should export getStoredKeypair', () => {
      expect(typeof powModule.getStoredKeypair).toBe('function');
    });
  });
});
