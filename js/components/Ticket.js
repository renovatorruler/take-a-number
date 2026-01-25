// Ticket.js - Red paper ticket component

const Ticket = ({ number, storeName, isRevealing = false }) => {
  const html = window.html;
  const { useState, useEffect } = preactHooks;
  
  const [revealed, setRevealed] = useState(!isRevealing);
  
  useEffect(() => {
    if (isRevealing) {
      // Delay reveal animation
      const timer = setTimeout(() => setRevealed(true), 100);
      return () => clearTimeout(timer);
    }
  }, [isRevealing]);
  
  return html`
    <div 
      class="paper-ticket ${revealed ? 'revealed' : ''}"
      data-testid="ticket"
      style="opacity: ${revealed ? 1 : 0}; transform: scale(${revealed ? 1 : 0.9}); transition: all 0.3s ease-out;"
    >
      ${storeName && html`
        <div class="ticket-store-name" data-testid="ticket-store-name">
          ${storeName}
        </div>
      `}
      <div class="ticket-number-display" data-testid="ticket-number">
        #${number}
      </div>
      <div class="ticket-your-number">Your Number</div>
    </div>
  `;
};

window.Ticket = Ticket;
