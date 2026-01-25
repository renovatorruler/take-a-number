// Landing.js - Create queue page with store name input, PoW, QR code generation

const Landing = () => {
  const html = window.html;
  const { useState } = preactHooks;
  
  // State
  const [storeName, setStoreName] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [createdStore, setCreatedStore] = useState(null);
  const [qrCodeUrl, setQrCodeUrl] = useState('');
  
  // Validation
  const validateStoreName = (name) => {
    const trimmed = name.trim();
    if (trimmed.length < 1) {
      return 'Store name is required';
    }
    if (trimmed.length > 50) {
      return 'Store name must be 50 characters or less';
    }
    // Check for potential XSS (basic)
    if (/<script|javascript:|on\w+=/i.test(trimmed)) {
      return 'Invalid characters in store name';
    }
    return null;
  };
  
  // Handle store creation
  const handleCreateStore = async (e) => {
    e.preventDefault();
    
    // Validate
    const validationError = validateStoreName(storeName);
    if (validationError) {
      setError(validationError);
      return;
    }
    
    setError('');
    setIsLoading(true);
    
    try {
      // Initialize Gun
      window.GunHelpers.initGun();
      
      // Generate keypair (includes PoW - takes ~2-3 seconds)
      await window.PoW.generateKeyPair();
      
      // Create the store
      const result = await window.GunHelpers.createStore(storeName.trim());
      
      // Generate QR code for customer URL
      const customerUrl = window.QRUtils.generateCustomerURL(result.storeId);
      const qrDataUrl = await window.QRUtils.generateQRCode(customerUrl);
      
      setQrCodeUrl(qrDataUrl);
      setCreatedStore({
        ...result,
        customerUrl,
        adminUrl: window.QRUtils.generateAdminURL(result.adminId)
      });
    } catch (err) {
      console.error('Failed to create store:', err);
      setError(err.message || 'Failed to create queue. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };
  
  // Handle QR code download
  const handleDownloadQR = () => {
    if (qrCodeUrl && createdStore) {
      const filename = `${createdStore.store.name.replace(/[^a-zA-Z0-9]/g, '-')}-qrcode.png`;
      window.QRUtils.downloadQRCode(qrCodeUrl, filename);
    }
  };
  
  // Handle copy admin URL
  const copyAdminUrl = async () => {
    if (createdStore) {
      try {
        await navigator.clipboard.writeText(createdStore.adminUrl);
        // Could add a toast notification here
      } catch (err) {
        console.error('Failed to copy:', err);
      }
    }
  };
  
  // Loading animation component
  const LoadingAnimation = () => html`
    <div class="loading-animation" data-testid="loading-animation">
      <div class="spinner-container">
        <div class="ticket-spinner">
          <div class="ticket-front">🎫</div>
        </div>
      </div>
      <p class="loading-text">Creating your queue...</p>
      <p class="loading-subtext">Generating secure keys (this takes a few seconds)</p>
    </div>
  `;
  
  // Success screen - show QR code and admin URL
  if (createdStore) {
    return html`
      <div class="page" data-testid="landing-page" data-store-id="${createdStore.storeId}">
        <div class="page-header">
          <h1 class="page-title">🎉 Queue Created!</h1>
          <p class="page-subtitle">${createdStore.store.name}</p>
        </div>
        
        <div class="container">
          <!-- Hidden element with customer URL for testing -->
          <input type="hidden" data-testid="customer-url" value="${createdStore.customerUrl}" />
          
          <div class="qr-section" data-testid="qr-section">
            <h2>Customer QR Code</h2>
            <p class="text-muted">Print this and display at your counter</p>
            
            <div class="qr-code-container">
              <img 
                src=${qrCodeUrl} 
                alt="Queue QR Code" 
                class="qr-code-image"
                data-testid="qr-code"
              />
            </div>
            
            <button 
              class="btn btn-primary mt-2"
              onClick=${handleDownloadQR}
              data-testid="download-qr"
            >
              📥 Download QR Code
            </button>
          </div>
          
          <div class="admin-section mt-4">
            <h2>Admin URL</h2>
            <p class="text-muted">Save this link to manage your queue</p>
            
            <div class="admin-url-container">
              <input 
                type="text" 
                value=${createdStore.adminUrl}
                readonly
                class="admin-url-input"
                data-testid="admin-url"
              />
              <button 
                class="btn btn-secondary"
                onClick=${copyAdminUrl}
                data-testid="copy-admin-url"
              >
                📋 Copy
              </button>
            </div>
            
            <p class="warning-text mt-2">
              ⚠️ Save this URL! It's the only way to access your admin panel.
            </p>
          </div>
          
          <div class="next-steps mt-4">
            <h3>Next Steps</h3>
            <ol>
              <li>Print the QR code and display it at your counter</li>
              <li>Bookmark the admin URL to manage your queue</li>
              <li>Customers scan the QR code to take a number</li>
            </ol>
          </div>
          
          <div class="actions mt-4">
            <a 
              href=${createdStore.adminUrl}
              class="btn btn-primary"
              data-testid="go-to-admin"
            >
              Go to Admin Panel →
            </a>
          </div>
        </div>
      </div>
    `;
  }
  
  // Main form
  return html`
    <div class="page" data-testid="landing-page">
      <div class="page-header">
        <h1 class="page-title">🎫 Take a Number</h1>
        <p class="page-subtitle">Queue management for your store. No app needed.</p>
      </div>
      
      <div class="container">
        ${isLoading ? html`<${LoadingAnimation} />` : html`
          <form onSubmit=${handleCreateStore} class="create-form">
            <div class="form-group">
              <label for="storeName" class="form-label">Store Name</label>
              <input
                type="text"
                id="storeName"
                value=${storeName}
                onInput=${(e) => setStoreName(e.target.value)}
                placeholder="e.g., Joe's Bakery"
                maxlength="50"
                class="form-input"
                data-testid="store-name-input"
                disabled=${isLoading}
              />
              <p class="form-hint">${storeName.length}/50 characters</p>
            </div>
            
            ${error && html`
              <div class="error-message" data-testid="error-message">
                ${error}
              </div>
            `}
            
            <button 
              type="submit" 
              class="btn btn-primary btn-full"
              disabled=${isLoading || !storeName.trim()}
              data-testid="create-queue-btn"
            >
              Create My Queue
            </button>
          </form>
          
          <div class="features mt-4">
            <h3>How it works</h3>
            <ul class="feature-list">
              <li>✨ Create your queue in seconds</li>
              <li>📱 Customers scan QR code to take a number</li>
              <li>🔔 Real-time updates for everyone</li>
              <li>🚫 No app download required</li>
            </ul>
          </div>
        `}
      </div>
    </div>
  `;
};

window.Landing = Landing;
