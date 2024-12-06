<script lang="ts">
  export let number: number;
  export let onRelinquish: () => void;
</script>

<div class="reserved-number">
  <h2>Your Number</h2>
  <div class="number">{number}</div>
  <button on:click={onRelinquish} class="relinquish-button">
    Relinquish Number
  </button>
</div>

<style>
  .reserved-number {
    margin: 20px 0;
    padding: 20px;
    background-color: #f8f9fa;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
  }

  .number {
    font-size: 48px;
    font-weight: bold;
    color: #2c3e50;
    margin: 20px 0;
  }

  .relinquish-button {
    padding: 12px 24px;
    font-size: 16px;
    background-color: #e74c3c;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s;
  }

  .relinquish-button:hover {
    background-color: #c0392b;
  }
</style> 