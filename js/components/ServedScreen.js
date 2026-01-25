// ServedScreen.js - Thank you screen with social follow prompt

const ServedScreen = ({ storeName, onTakeAnother }) => {
  const html = window.html;
  
  // Placeholder Twitter handle (would come from store settings in v2)
  const twitterHandle = '@storename';
  
  const handleTakeAnother = () => {
    if (onTakeAnother) {
      onTakeAnother();
    }
  };
  
  return html`
    <div class="served-screen" data-testid="served-screen">
      <div class="served-checkmark">✓</div>
      <h1 class="served-title">Thanks for visiting!</h1>
      <p class="served-message">We hope to see you again soon.</p>
      
      <div class="social-prompt" data-testid="social-prompt">
        <h3>Follow ${storeName || 'us'}</h3>
        <p class="social-handle">${twitterHandle}</p>
        <a 
          href="https://twitter.com/${twitterHandle.replace('@', '')}"
          target="_blank"
          rel="noopener noreferrer"
          class="social-link"
          data-testid="twitter-link"
        >
          🐦 Follow on Twitter
        </a>
      </div>
      
      <button 
        class="btn btn-secondary"
        onClick=${handleTakeAnother}
        data-testid="take-another-btn"
      >
        Take Another Number
      </button>
    </div>
  `;
};

window.ServedScreen = ServedScreen;
