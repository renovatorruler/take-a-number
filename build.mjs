import * as esbuild from 'esbuild';

// Plugin to redirect react imports to preact/compat
const preactCompatPlugin = {
  name: 'preact-compat',
  setup(build) {
    // Redirect react imports to use globals
    build.onResolve({ filter: /^react$/ }, args => ({
      path: args.path,
      namespace: 'preact-shim',
    }));
    build.onResolve({ filter: /^react\/jsx-runtime$/ }, args => ({
      path: args.path,
      namespace: 'preact-shim',
    }));
    build.onResolve({ filter: /^react-dom$/ }, args => ({
      path: args.path,
      namespace: 'preact-shim',
    }));
    
    // Provide shims that use globals
    build.onLoad({ filter: /.*/, namespace: 'preact-shim' }, args => {
      if (args.path === 'react' || args.path === 'react-dom') {
        return {
          contents: `
            var preact = window.preact;
            var hooks = window.preactHooks;
            module.exports = {
              createElement: preact.h,
              Fragment: preact.Fragment,
              Component: preact.Component,
              createContext: preact.createContext,
              createRef: preact.createRef,
              useState: hooks.useState,
              useEffect: hooks.useEffect,
              useRef: hooks.useRef,
              useCallback: hooks.useCallback,
              useMemo: hooks.useMemo,
              useContext: hooks.useContext,
              useReducer: hooks.useReducer,
              render: preact.render,
              hydrate: preact.hydrate,
            };
          `,
          loader: 'js',
        };
      }
      if (args.path === 'react/jsx-runtime') {
        return {
          contents: `
            var preact = window.preact;
            module.exports = {
              jsx: preact.h,
              jsxs: preact.h,
              jsxDEV: preact.h,
              Fragment: preact.Fragment,
            };
          `,
          loader: 'js',
        };
      }
    });
  },
};

await esbuild.build({
  entryPoints: ['lib/es6/src/App.js'],
  bundle: true,
  format: 'iife',
  globalName: 'TakeANumber',
  outfile: 'dist/app.bundle.js',
  plugins: [preactCompatPlugin],
  define: {
    'process.env.NODE_ENV': '"production"'
  },
  minify: false,
  sourcemap: true,
});

console.log('Build complete: dist/app.bundle.js');
