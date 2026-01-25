// app.js - Main app entry point with routing

// Setup Preact + HTM
const { h, render } = preact;
const { useState, useEffect } = preactHooks;
const html = htm.bind(h);

// Make html available globally for components
window.html = html;

// Router component
function Router() {
  const [route, setRoute] = useState(window.location.hash || '#/');
  
  useEffect(() => {
    const onHashChange = () => {
      setRoute(window.location.hash || '#/');
    };
    window.addEventListener('hashchange', onHashChange);
    return () => window.removeEventListener('hashchange', onHashChange);
  }, []);
  
  // Parse route and render appropriate component
  // #/q/{storeId} - Customer queue page
  if (route.startsWith('#/q/')) {
    const storeId = route.slice(4);
    return html`<${window.Queue} storeId=${storeId} />`;
  }
  
  // #/admin/{adminId} - Operator admin panel
  if (route.startsWith('#/admin/')) {
    const adminId = route.slice(8);
    return html`<${window.Admin} adminId=${adminId} />`;
  }
  
  // #/display/{storeId} - TV display screen
  if (route.startsWith('#/display/')) {
    const storeId = route.slice(10);
    return html`<${window.Display} storeId=${storeId} />`;
  }
  
  // Default: Landing page
  return html`<${window.Landing} />`;
}

// App wrapper
function App() {
  return html`<${Router} />`;
}

// Mount the app
render(html`<${App} />`, document.getElementById('app'));

console.log('Take a Number app initialized');
