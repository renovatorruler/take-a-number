// Admin.js - Operator admin panel
// Component will be implemented in m1-t4

const Admin = ({ adminId }) => {
  const html = window.html;
  
  return html`
    <div class="page" data-testid="admin-page">
      <div class="page-header">
        <h1 class="page-title">Admin Panel</h1>
        <p class="page-subtitle">Admin: ${adminId}</p>
      </div>
      
      <div class="container">
        <p class="text-center">Admin panel - coming soon</p>
      </div>
    </div>
  `;
};

window.Admin = Admin;
