<script lang="ts">
  import { slide } from 'svelte/transition';
  import HamburgerMenu from '$lib/components/HamburgerMenu.svelte';
  import { writable } from 'svelte/store';

  const isMenuOpen = writable(false);
  
  function toggleMenu() {
    $isMenuOpen = !$isMenuOpen;
  }
</script>

<div class="layout">
  <header>
    <div class="header-content">
      <h1>Take a Number</h1>
      <HamburgerMenu isOpen={$isMenuOpen} onToggle={toggleMenu} />
    </div>
  </header>

  <main>
    <slot />
  </main>
</div>

<style>
  :global(body) {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
    background-color: #f5f5f5;
  }

  .layout {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  header {
    background: white;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    padding: 1rem;
    position: sticky;
    top: 0;
    z-index: 100;
  }

  .header-content {
    max-width: 600px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 20px;
  }

  h1 {
    margin: 0;
    font-size: 1.5rem;
    color: #2c3e50;
    font-weight: 600;
  }

  main {
    flex: 1;
    width: 100%;
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    box-sizing: border-box;
  }
</style> 