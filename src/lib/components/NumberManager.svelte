<script lang="ts">
  import { numberManagerComponent } from '@res/lib/components/NumberManager.mjs';
  
  const { numberStore, handleTakeNumber } = numberManagerComponent();
</script>

<div class="number-display">
  <h2>Current Number</h2>
  <div class="number">{$numberStore}</div>
  <button on:click={handleTakeNumber} class="primary-button">
    Take a Number
  </button>
</div>

<style>
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