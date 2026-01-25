// Display.js - TV display screen
// Component will be implemented in m1-t4

const Display = ({ storeId }) => {
  const html = window.html;
  
  return html`
    <div class="page" data-testid="display-page">
      <div class="page-header">
        <h1 class="page-title">Display</h1>
        <p class="page-subtitle">Store: ${storeId}</p>
      </div>
      
      <div class="container">
        <p class="text-center">Display screen - coming soon</p>
      </div>
    </div>
  `;
};

window.Display = Display;
