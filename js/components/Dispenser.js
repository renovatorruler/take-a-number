// Dispenser.js - Drag-to-pull ticket dispenser component

const Dispenser = ({ onPull, isDisabled = false }) => {
  const html = window.html;
  const { useState, useRef, useEffect } = preactHooks;
  
  const [isDragging, setIsDragging] = useState(false);
  const [dragProgress, setDragProgress] = useState(0);
  const containerRef = useRef(null);
  const startYRef = useRef(0);
  const PULL_THRESHOLD = 80; // pixels to pull to trigger
  
  // Handle drag/touch start
  const handleStart = (e) => {
    if (isDisabled) return;
    
    e.preventDefault();
    setIsDragging(true);
    
    const clientY = e.type === 'touchstart' 
      ? e.touches[0].clientY 
      : e.clientY;
    startYRef.current = clientY;
  };
  
  // Handle drag/touch move
  const handleMove = (e) => {
    if (!isDragging || isDisabled) return;
    
    const clientY = e.type === 'touchmove' 
      ? e.touches[0].clientY 
      : e.clientY;
    
    const deltaY = clientY - startYRef.current;
    const progress = Math.min(Math.max(deltaY, 0), PULL_THRESHOLD);
    setDragProgress(progress);
  };
  
  // Handle drag/touch end
  const handleEnd = () => {
    if (!isDragging || isDisabled) return;
    
    setIsDragging(false);
    
    if (dragProgress >= PULL_THRESHOLD) {
      // Trigger the pull action
      if (onPull) {
        onPull();
      }
    }
    
    setDragProgress(0);
  };
  
  // Handle simple tap/click
  const handleClick = (e) => {
    if (isDisabled || isDragging || dragProgress > 5) return;
    
    if (onPull) {
      onPull();
    }
  };
  
  // Add global mouse/touch listeners when dragging
  useEffect(() => {
    if (!isDragging) return;
    
    const handleGlobalMove = (e) => handleMove(e);
    const handleGlobalEnd = () => handleEnd();
    
    window.addEventListener('mousemove', handleGlobalMove);
    window.addEventListener('mouseup', handleGlobalEnd);
    window.addEventListener('touchmove', handleGlobalMove, { passive: true });
    window.addEventListener('touchend', handleGlobalEnd);
    
    return () => {
      window.removeEventListener('mousemove', handleGlobalMove);
      window.removeEventListener('mouseup', handleGlobalEnd);
      window.removeEventListener('touchmove', handleGlobalMove);
      window.removeEventListener('touchend', handleGlobalEnd);
    };
  }, [isDragging, dragProgress]);
  
  const progressPercent = (dragProgress / PULL_THRESHOLD) * 100;
  const ticketOffset = Math.min(dragProgress * 0.5, 40);
  
  return html`
    <div 
      class="dispenser-container"
      ref=${containerRef}
      data-testid="dispenser"
    >
      <div 
        class="dispenser ${isDisabled ? 'disabled' : ''}"
        onMouseDown=${handleStart}
        onTouchStart=${handleStart}
        onClick=${handleClick}
        style="cursor: ${isDisabled ? 'not-allowed' : 'grab'}; opacity: ${isDisabled ? 0.7 : 1};"
        data-testid="dispenser-pull-area"
      >
        <div class="dispenser-label">Take a Number</div>
        <div class="dispenser-hint">
          ${isDisabled ? 'Please wait...' : '↓ Tap or drag down ↓'}
        </div>
        <div class="dispenser-slot"></div>
      </div>
      
      <!-- Preview ticket emerging -->
      <div 
        class="ticket-emerging ${dragProgress > 0 ? 'pulling' : ''}"
        style="transform: translateY(${ticketOffset}px); opacity: ${progressPercent / 100};"
        data-testid="ticket-preview"
      >
        <div class="paper-ticket" style="padding: 0.75rem;">
          <div style="font-size: 2rem; font-weight: 900; text-align: center;">?</div>
        </div>
      </div>
      
      ${isDragging && html`
        <div class="pull-indicator" style="
          position: absolute; 
          bottom: -30px; 
          left: 50%; 
          transform: translateX(-50%);
          font-size: 0.75rem;
          color: var(--color-gray);
        ">
          ${progressPercent >= 100 ? 'Release!' : `Pull... ${Math.round(progressPercent)}%`}
        </div>
      `}
    </div>
  `;
};

window.Dispenser = Dispenser;
