// App.res - Main app entry point with routing

// Route type
type route =
  | Landing
  | CustomerQueue(string)
  | AdminPanel(string)
  | DisplayScreen(string)

// Parse hash route
let parseRoute = (hash: string): route => {
  let h = if hash == "" { "#/" } else { hash }

  // #/q/{storeId} - Customer queue page
  if h->String.startsWith("#/q/") {
    let storeId = h->String.slice(~start=4, ~end=100)
    CustomerQueue(storeId)
  } else if h->String.startsWith("#/admin/") {
    // #/admin/{adminId} - Operator admin panel
    let adminId = h->String.slice(~start=8, ~end=100)
    AdminPanel(adminId)
  } else if h->String.startsWith("#/display/") {
    // #/display/{storeId} - TV display screen
    let storeId = h->String.slice(~start=10, ~end=100)
    DisplayScreen(storeId)
  } else {
    // Default: Landing page
    Landing
  }
}

// Router component
module Router = {
  @react.component
  let make = () => {
    let (route, setRoute) = React.useState(() => parseRoute(Browser.Location.hash))

    React.useEffect0(() => {
      let onHashChange = _ => {
        setRoute(_ => parseRoute(Browser.Location.hash))
      }

      Browser.Window.addEventListener("hashchange", onHashChange)

      Some(() => Browser.Window.removeEventListener("hashchange", onHashChange))
    })

    switch route {
    | Landing => <Landing.make />
    | CustomerQueue(storeId) => <Queue.make storeId />
    | AdminPanel(adminId) => <Admin.make adminId />
    | DisplayScreen(storeId) => <Display.make storeId />
    }
  }
}

// App wrapper
module App = {
  @react.component
  let make = () => {
    <Router />
  }
}

// Initialize - expose all components and libs to window
let init = () => {
  // Expose lib modules
  Storage.expose()
  Pow.expose()
  GunHelpers.expose()
  QRUtils.expose()

  // Expose components
  Ticket.expose()
  Dispenser.expose()
  ServedScreen.expose()
  Landing.expose()
  Queue.expose()
  Admin.expose()
  Display.expose()

  // Mount the app - use raw JS for Preact rendering
  let mountApp: Browser.element => unit = %raw(`
    function(container) {
      var h = window.preact.h;
      var render = window.preact.render;
      var useState = window.preactHooks.useState;
      var useEffect = window.preactHooks.useEffect;
      var html = window.htm.bind(h);
      window.html = html;
      
      function Router() {
        var routeState = useState(window.location.hash || '#/');
        var route = routeState[0];
        var setRoute = routeState[1];
        
        useEffect(function() {
          var onHashChange = function() {
            setRoute(window.location.hash || '#/');
          };
          window.addEventListener('hashchange', onHashChange);
          return function() { 
            window.removeEventListener('hashchange', onHashChange); 
          };
        }, []);
        
        if (route.startsWith('#/q/')) {
          var storeId = route.slice(4);
          return h(window.Queue, { storeId: storeId });
        }
        
        if (route.startsWith('#/admin/')) {
          var adminId = route.slice(8);
          return h(window.Admin, { adminId: adminId });
        }
        
        if (route.startsWith('#/display/')) {
          var storeId = route.slice(10);
          return h(window.Display, { storeId: storeId });
        }
        
        return h(window.Landing, {});
      }
      
      render(h(Router, {}), container);
    }
  `)

  switch Browser.Document.getElementById("app") {
  | Some(container) => {
      mountApp(container)
      Browser.Console.log("Take a Number app initialized")
    }
  | None => Browser.Console.error("Could not find #app element")
  }
}

// Auto-initialize when loaded
let _ = init()
