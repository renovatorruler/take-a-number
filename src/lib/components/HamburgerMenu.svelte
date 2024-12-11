<script lang="ts">
  import { slide } from "svelte/transition";
  export let isOpen = false;
  export let onToggle: () => void;
</script>

<div class="menu-container">
  <button
    class="hamburger"
    class:open={isOpen}
    on:click={onToggle}
    aria-label="Menu"
  >
    <span></span>
    <span></span>
    <span></span>
  </button>

  {#if isOpen}
    <button
      class="menu-content"
      transition:slide
      on:click|self={onToggle}
      on:keydown|self={(e) => e.key === "Escape" && onToggle()}
      aria-label="Close menu"
    >
      <nav>
        <ul>
          <li><a href="/" on:click={onToggle}>Home</a></li>
          <li><a href="/create" on:click={onToggle}>Create Location</a></li>
          <li><a href="/about" on:click={onToggle}>About</a></li>
          <li><a href="/settings" on:click={onToggle}>Settings</a></li>
        </ul>
      </nav>
    </button>
  {/if}
</div>

<style>
  .menu-container {
    position: relative;
  }

  .hamburger {
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    width: 2rem;
    height: 2rem;
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 0;
    z-index: 100;
  }

  .hamburger span {
    width: 2rem;
    height: 0.25rem;
    background: #2c3e50;
    border-radius: 10px;
    transition: all 0.3s linear;
    position: relative;
    transform-origin: 1px;
  }

  .hamburger.open span {
    background: #2c3e50;
  }

  .hamburger.open span:first-child {
    transform: rotate(45deg);
  }

  .hamburger.open span:nth-child(2) {
    opacity: 0;
  }

  .hamburger.open span:last-child {
    transform: rotate(-45deg);
  }

  .menu-content {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    padding: 1rem;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    min-width: 200px;
  }

  nav ul {
    list-style: none;
    padding: 0;
    margin: 0;
  }

  nav li {
    margin: 0.5rem 0;
  }

  nav a {
    color: #2c3e50;
    text-decoration: none;
    font-size: 1rem;
    transition: color 0.3s ease;
    display: block;
    padding: 0.5rem 1rem;
  }

  nav a:hover {
    background-color: #f5f5f5;
    border-radius: 4px;
  }

  @media (max-width: 768px) {
    .menu-content {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      width: 100%;
      height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: rgba(255, 255, 255, 0.98);
      cursor: pointer;
    }

    nav {
      cursor: default;
    }

    nav ul {
      text-align: center;
    }

    nav li {
      margin: 1rem 0;
    }

    nav a {
      font-size: 1.2rem;
      padding: 1rem 2rem;
    }

    .hamburger.open {
      position: fixed;
      top: 1rem;
      right: 1rem;
    }
  }
</style>
