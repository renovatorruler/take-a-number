<script lang="ts">
  import { numberManagerComponent } from "@res/lib/components/NumberManager.mjs";
  import ReservedNumber from "./ReservedNumber.svelte";

  export let locationId;
  console.log("NumberManager component locationId:", locationId);
  const {
    numberStore,
    reservedNumberStore,
    handleTakeNumber,
    handleRelinquishNumber,
  } = numberManagerComponent(locationId);

  // Add debug logging
  $: console.log("reservedNumberStore value:", $reservedNumberStore);
</script>

<div class="ticket-machine">
  <div class="ticket-slot">
    {#if $reservedNumberStore}
      <ReservedNumber
        number={$reservedNumberStore}
        onRelinquish={handleRelinquishNumber}
      />
    {/if}

    <div class="ticket">
      <div class="ticket-header">
        <div class="ticket-holes">
          <div class="hole"></div>
          <div class="hole"></div>
          <div class="hole"></div>
          <div class="hole"></div>
        </div>
      </div>
      <div class="ticket-content">
        <h2>Current Number</h2>
        <div class="number">
          {#if $numberStore === undefined || $numberStore === null}
            <div class="loading">Loading...</div>
          {:else}
            {$numberStore}
          {/if}
        </div>
        {#if !$reservedNumberStore}
          <button
            on:click={handleTakeNumber}
            class="primary-button"
            disabled={$numberStore === undefined || $numberStore === null}
          >
            Take a Number
          </button>
        {/if}
      </div>
    </div>
  </div>
</div>

<style>
  .ticket-machine {
    background: #2c3e50;
    padding: 30px;
    border-radius: 15px;
    box-shadow:
      0 10px 20px rgba(0, 0, 0, 0.2),
      inset 0 -5px 10px rgba(0, 0, 0, 0.3);
  }

  .ticket-slot {
    background: #34495e;
    padding: 10px;
    border-radius: 8px;
    box-shadow: inset 0 2px 5px rgba(0, 0, 0, 0.2);
  }

  .ticket {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    transform-origin: top center;
    animation: slideIn 0.5s ease-out;
  }

  .ticket-header {
    padding: 10px;
    background: #f8f9fa;
    border-bottom: 2px dashed #dee2e6;
  }

  .ticket-holes {
    display: flex;
    justify-content: space-around;
    padding: 0 20px;
  }

  .hole {
    width: 8px;
    height: 8px;
    background: #e9ecef;
    border-radius: 50%;
    box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.2);
  }

  .ticket-content {
    padding: 20px;
    text-align: center;
  }

  h2 {
    color: #2c3e50;
    margin: 0 0 20px 0;
    font-size: 1.5rem;
  }

  .number {
    font-size: 72px;
    font-weight: bold;
    color: #2c3e50;
    margin: 20px 0;
    font-family: "Courier New", monospace;
  }

  .primary-button {
    padding: 15px 30px;
    font-size: 18px;
    background-color: #3498db;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  }

  .primary-button:hover {
    background-color: #2980b9;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  .primary-button:active {
    transform: translateY(0);
  }

  .primary-button:disabled {
    background-color: #ccc;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .loading {
    font-size: 1.5rem;
    color: #666;
    font-style: italic;
  }

  @keyframes slideIn {
    from {
      transform: translateY(-20px);
      opacity: 0;
    }
    to {
      transform: translateY(0);
      opacity: 1;
    }
  }

  /* Add some responsive adjustments */
  @media (max-width: 768px) {
    .ticket-machine {
      padding: 20px;
    }

    .number {
      font-size: 56px;
    }

    .primary-button {
      padding: 12px 24px;
      font-size: 16px;
    }
  }
</style>
