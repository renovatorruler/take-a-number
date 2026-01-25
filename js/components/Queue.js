// Queue.js - Customer queue page
// Component will be implemented in m1-t5

const Queue = ({ storeId }) => {
  const html = window.html;
  
  return html`
    <div class="page" data-testid="queue-page">
      <div class="page-header">
        <h1 class="page-title">Queue</h1>
        <p class="page-subtitle">Store: ${storeId}</p>
      </div>
      
      <div class="container">
        <p class="text-center">Queue page - coming soon</p>
      </div>
    </div>
  `;
};

window.Queue = Queue;
