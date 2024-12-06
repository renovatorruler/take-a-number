<script lang="ts">
  import { onMount } from 'svelte';
  import { gun, numbers } from '@res/lib/Db.mjs';

  let currentNumber = 0;

  onMount(() => {
    numbers.get('current').on((number) => {
      if (number) {
        currentNumber = number;
      }
    });
  });

  function takeNumber() {
    numbers.get('current').once((number) => {
      const nextNumber = (parseInt(number) || 0) + 1;
      numbers.get('current').put(nextNumber);
    });
  }
</script>

<div class="container">
  <h1>Take a Number</h1>
  <div id="current-number" class="number-display">
    <h2>Current Number</h2>
    <div class="number">{currentNumber}</div>
  </div>
  <button on:click={takeNumber} class="primary-button">Take a Number</button>
</div>

<style>
  .container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    text-align: center;
  }

  .number-display {
    margin: 40px 0;
    padding: 20px;
    background-color: white;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .number {
    font-size: 72px;
    font-weight: bold;
    color: #2c3e50;
    margin: 20px 0;
  }

  .primary-button {
    padding: 15px 30px;
    font-size: 18px;
    background-color: #3498db;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
  }

  .primary-button:hover {
    background-color: #2980b9;
  }
</style>
