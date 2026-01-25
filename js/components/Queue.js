// Queue.js - Customer queue page with ticket dispenser
// Full implementation for m1-t5

const Queue = ({ storeId }) => {
  const html = window.html;
  const { useState, useEffect, useRef } = preactHooks;
  
  // State
  const [store, setStore] = useState(null);
  const [ticket, setTicket] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isTakingNumber, setIsTakingNumber] = useState(false);
  const [showServedScreen, setShowServedScreen] = useState(false);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);
  
  // Check for incognito mode
  const [isIncognito, setIsIncognito] = useState(false);
  
  // Unsubscribe function ref
  const unsubscribeRef = useRef(null);
  
  // Check for incognito mode on mount
  useEffect(() => {
    if (window.Storage && window.Storage.isIncognito()) {
      setIsIncognito(true);
      setIsLoading(false);
      return;
    }
    
    // Initialize Gun
    window.GunHelpers.initGun();
    
    // Load store data
    loadStore();
    
    // Check for existing ticket
    checkExistingTicket();
    
    return () => {
      // Cleanup subscription
      if (unsubscribeRef.current) {
        unsubscribeRef.current();
      }
    };
  }, [storeId]);
  
  // Subscribe to store updates
  useEffect(() => {
    if (!store) return;
    
    unsubscribeRef.current = window.GunHelpers.subscribeToStore(storeId, (updatedStore) => {
      setStore(updatedStore);
    });
    
    return () => {
      if (unsubscribeRef.current) {
        unsubscribeRef.current();
      }
    };
  }, [storeId, store?.id]);
  
  const loadStore = async () => {
    try {
      const storeData = await window.GunHelpers.getStore(storeId);
      if (!storeData) {
        setError('Queue not found');
      } else {
        setStore(storeData);
      }
    } catch (err) {
      console.error('Failed to load store:', err);
      setError('Failed to load queue');
    } finally {
      setIsLoading(false);
    }
  };
  
  const checkExistingTicket = async () => {
    // Check localStorage for existing ticket
    if (window.Storage && window.Storage.hasTicket(storeId)) {
      const storedTicket = window.Storage.getTicket(storeId);
      if (storedTicket && storedTicket.status === 'waiting') {
        setTicket(storedTicket);
      } else if (storedTicket && storedTicket.status === 'served') {
        setShowServedScreen(true);
      }
    }
  };
  
  const handleTakeNumber = async () => {
    if (isTakingNumber) return;
    
    setIsTakingNumber(true);
    setError(null);
    
    try {
      // Generate keypair (includes PoW - takes ~2-3 seconds)
      const keypair = await window.PoW.generateKeyPair();
      const deviceId = await window.PoW.getDeviceId(keypair);
      
      // Check if device already has a ticket
      const existingTicket = await window.GunHelpers.getTicketByDeviceId(storeId, deviceId);
      if (existingTicket && existingTicket.status === 'waiting') {
        setTicket(existingTicket);
        window.Storage.storeTicket(storeId, existingTicket);
        return;
      }
      
      // Create new ticket
      const newTicket = await window.GunHelpers.createTicket(storeId, deviceId);
      setTicket(newTicket);
      
      // Store in localStorage
      window.Storage.storeTicket(storeId, newTicket);
    } catch (err) {
      console.error('Failed to take number:', err);
      setError(err.message || 'Failed to get ticket. Please try again.');
    } finally {
      setIsTakingNumber(false);
    }
  };
  
  const handleMarkServed = () => {
    if (!ticket) return;
    setShowConfirmDialog(true);
  };
  
  const handleConfirmServed = async () => {
    setShowConfirmDialog(false);
    
    try {
      await window.GunHelpers.markTicketServed(storeId, ticket.number, 'self');
      
      // Update local ticket
      const updatedTicket = { ...ticket, status: 'served' };
      setTicket(updatedTicket);
      window.Storage.storeTicket(storeId, updatedTicket);
      
      setShowServedScreen(true);
    } catch (err) {
      console.error('Failed to mark as served:', err);
      setError('Failed to mark as served. Please try again.');
    }
  };
  
  const handleCancelServed = () => {
    setShowConfirmDialog(false);
  };
  
  const handleTakeAnother = () => {
    window.Storage.clearTicket(storeId);
    setTicket(null);
    setShowServedScreen(false);
  };
  
  // Calculate position in queue
  const getPosition = () => {
    if (!ticket || !store) return null;
    const nowServing = store.nowServing || 0;
    const position = ticket.number - nowServing;
    return Math.max(0, position);
  };
  
  // Format expiry time (24 hours from issue)
  const getExpiryTime = () => {
    if (!ticket) return null;
    const expiryTime = ticket.issuedAt + (24 * 60 * 60 * 1000);
    const now = Date.now();
    const remaining = expiryTime - now;
    
    if (remaining <= 0) return 'Expired';
    
    const hours = Math.floor(remaining / (60 * 60 * 1000));
    const minutes = Math.floor((remaining % (60 * 60 * 1000)) / (60 * 1000));
    
    return `${hours}h ${minutes}m`;
  };
  
  // Incognito mode blocked screen
  if (isIncognito) {
    return html`
      <div class="page" data-testid="queue-page">
        <div class="page-header">
          <h1 class="page-title">🔒 Private Mode</h1>
        </div>
        <div class="container">
          <div class="incognito-warning" data-testid="incognito-warning">
            <p>Please open this page in a regular browser window.</p>
            <p>Private/Incognito mode is not supported because we need to remember your ticket.</p>
          </div>
        </div>
      </div>
    `;
  }
  
  // Loading state
  if (isLoading) {
    return html`
      <div class="page" data-testid="queue-page">
        <div class="loading">Loading...</div>
      </div>
    `;
  }
  
  // Error state - store not found
  if (error && !store) {
    return html`
      <div class="page" data-testid="queue-page">
        <div class="page-header">
          <h1 class="page-title">Queue Not Found</h1>
        </div>
        <div class="container">
          <div class="error" data-testid="queue-error">
            <p>${error}</p>
            <p>Please check the QR code and try again.</p>
          </div>
        </div>
      </div>
    `;
  }
  
  // Served screen
  if (showServedScreen) {
    return html`<${window.ServedScreen} 
      storeName=${store?.name}
      onTakeAnother=${handleTakeAnother}
    />`;
  }
  
  // Confirmation dialog component
  const ConfirmDialog = () => html`
    <div class="confirm-dialog-overlay" data-testid="confirm-dialog">
      <div class="confirm-dialog">
        <h3>Mark as Served?</h3>
        <p>This will remove you from the queue.</p>
        <div class="confirm-dialog-buttons">
          <button 
            class="btn btn-outline"
            onClick=${handleCancelServed}
            data-testid="cancel-btn"
          >
            Cancel
          </button>
          <button 
            class="btn btn-primary"
            onClick=${handleConfirmServed}
            data-testid="confirm-btn"
          >
            Yes, I'm Done
          </button>
        </div>
      </div>
    </div>
  `;
  
  // Has ticket - show ticket and queue position
  if (ticket && ticket.status === 'waiting') {
    const position = getPosition();
    const expiryTime = getExpiryTime();
    
    return html`
      <div class="page" data-testid="queue-page">
        ${showConfirmDialog && html`<${ConfirmDialog} />`}
        <div class="page-header">
          <h1 class="page-title" data-testid="store-name">${store.name}</h1>
        </div>
        
        <div class="container">
          <${window.Ticket} 
            number=${ticket.number}
            storeName=${store.name}
            isRevealing=${true}
          />
          
          <div class="queue-status mt-3" data-testid="queue-status">
            <div class="status-item">
              <span class="status-label">Now Serving</span>
              <span class="status-value" data-testid="now-serving">
                #${store.nowServing || 0}
              </span>
            </div>
            <div class="status-item">
              <span class="status-label">Ahead of You</span>
              <span class="status-value" data-testid="people-ahead">
                ${position} ${position === 1 ? 'person' : 'people'}
              </span>
            </div>
          </div>
          
          ${position === 0 && html`
            <div class="your-turn-alert" data-testid="your-turn">
              🔔 It's your turn!
            </div>
          `}
          
          <button 
            class="btn btn-primary btn-full mt-3"
            onClick=${handleMarkServed}
            data-testid="mark-served-btn"
          >
            I've Been Served ✓
          </button>
          
          ${expiryTime && html`
            <div class="expiry-info mt-2" data-testid="expiry-info">
              ⏰ Expires in ${expiryTime}
            </div>
          `}
          
          ${error && html`
            <div class="error-message mt-2">${error}</div>
          `}
          
          <div class="pwa-prompt mt-4" data-testid="pwa-prompt">
            <p>📱 Add to Home Screen for notifications</p>
          </div>
        </div>
      </div>
    `;
  }
  
  // No ticket - show dispenser
  return html`
    <div class="page" data-testid="queue-page">
      <div class="page-header">
        <h1 class="page-title" data-testid="store-name">${store.name}</h1>
      </div>
      
      <div class="container">
        <${window.Dispenser} 
          onPull=${handleTakeNumber}
          isDisabled=${isTakingNumber}
        />
        
        ${isTakingNumber && html`
          <div class="taking-number-animation" data-testid="taking-number">
            <div class="ticket-spinner">🎫</div>
            <p>Getting your number...</p>
          </div>
        `}
        
        ${error && html`
          <div class="error-message mt-2" data-testid="error-message">
            ${error}
          </div>
        `}
        
        <div class="current-status mt-4">
          <div class="status">
            <span class="status-label">Now Serving</span>
            <span class="status-value" data-testid="now-serving">#${store.nowServing || 0}</span>
          </div>
        </div>
      </div>
    </div>
  `;
};

window.Queue = Queue;
