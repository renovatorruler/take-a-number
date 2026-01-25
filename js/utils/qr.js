// qr.js - QR Code generation utility using qrcode.js

/**
 * Generate QR code as data URL
 * @param {string} text - Text to encode in QR code
 * @param {object} options - QR code options
 * @returns {Promise<string>} Data URL of QR code image
 */
async function generateQRCode(text, options = {}) {
  // Check if QRCode is available
  if (typeof QRCode === 'undefined') {
    throw new Error('QRCode library is not loaded');
  }
  
  const defaultOptions = {
    width: 256,
    height: 256,
    margin: 2,
    color: {
      dark: '#212121',
      light: '#FFFFFF'
    },
    errorCorrectionLevel: 'M'
  };
  
  const finalOptions = { ...defaultOptions, ...options };
  
  return new Promise((resolve, reject) => {
    QRCode.toDataURL(text, finalOptions, (error, url) => {
      if (error) {
        reject(error);
      } else {
        resolve(url);
      }
    });
  });
}

/**
 * Generate QR code and render to canvas
 * @param {HTMLCanvasElement} canvas - Canvas element to render to
 * @param {string} text - Text to encode
 * @param {object} options - QR code options
 * @returns {Promise<void>}
 */
async function renderQRCodeToCanvas(canvas, text, options = {}) {
  if (typeof QRCode === 'undefined') {
    throw new Error('QRCode library is not loaded');
  }
  
  const defaultOptions = {
    width: 256,
    margin: 2,
    color: {
      dark: '#212121',
      light: '#FFFFFF'
    }
  };
  
  const finalOptions = { ...defaultOptions, ...options };
  
  return new Promise((resolve, reject) => {
    QRCode.toCanvas(canvas, text, finalOptions, (error) => {
      if (error) {
        reject(error);
      } else {
        resolve();
      }
    });
  });
}

/**
 * Download QR code as PNG
 * @param {string} dataUrl - QR code data URL
 * @param {string} filename - Filename for download
 */
function downloadQRCode(dataUrl, filename = 'qrcode.png') {
  const link = document.createElement('a');
  link.download = filename;
  link.href = dataUrl;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

/**
 * Generate customer queue URL
 * @param {string} storeId - Store ID
 * @returns {string} Full URL for customer queue page
 */
function generateCustomerURL(storeId) {
  const baseUrl = window.location.origin + window.location.pathname;
  return `${baseUrl}#/q/${storeId}`;
}

/**
 * Generate admin URL
 * @param {string} adminId - Admin ID
 * @returns {string} Full URL for admin page
 */
function generateAdminURL(adminId) {
  const baseUrl = window.location.origin + window.location.pathname;
  return `${baseUrl}#/admin/${adminId}`;
}

// Export for both browser and Node.js
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    generateQRCode,
    renderQRCodeToCanvas,
    downloadQRCode,
    generateCustomerURL,
    generateAdminURL
  };
} else if (typeof window !== 'undefined') {
  window.QRUtils = {
    generateQRCode,
    renderQRCodeToCanvas,
    downloadQRCode,
    generateCustomerURL,
    generateAdminURL
  };
}
