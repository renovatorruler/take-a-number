<script lang="ts">
  // Type can be either a number directly or an unboxed type
  type NumberValue = number | { _0: number };

  export let number: NumberValue | null;
  export let onRelinquish: () => void;

  // Extract the number value regardless of format
  $: displayNumber = typeof number === "number" ? number : number?._0;
</script>

<div class="ticket">
  <div class="torn-edge">
    <svg viewBox="0 0 100 20" preserveAspectRatio="none">
      <path
        d="
        M 0,20 
        C 0,20 1.5,18.5 3,19.5 
        C 4.5,20.5 6,18 8,18.5 
        C 10,19 12,17 14,17.5 
        C 16,18 18,16.5 20,17 
        C 22,17.5 24,19 26,18.5 
        C 28,18 30,16 32,16.5 
        C 34,17 36,19 38,18.5 
        C 40,18 42,16 44,16.5 
        C 46,17 48,19 50,18.5 
        C 52,18 54,16 56,16.5 
        C 58,17 60,19 62,18.5 
        C 64,18 66,16 68,16.5 
        C 70,17 72,19 74,18.5 
        C 76,18 78,16 80,16.5 
        C 82,17 84,19 86,18.5 
        C 88,18 90,16 92,16.5 
        C 94,17 96,19 98,18.5 
        L 100,18 
        L 100,0 
        L 0,0 
        Z"
        fill="white"
      />
      <path
        d="
        M 0,20 
        C 0,20 1.5,18.5 3,19.5 
        C 4.5,20.5 6,18 8,18.5 
        C 10,19 12,17 14,17.5 
        C 16,18 18,16.5 20,17 
        C 22,17.5 24,19 26,18.5 
        C 28,18 30,16 32,16.5 
        C 34,17 36,19 38,18.5 
        C 40,18 42,16 44,16.5 
        C 46,17 48,19 50,18.5 
        C 52,18 54,16 56,16.5 
        C 58,17 60,19 62,18.5 
        C 64,18 66,16 68,16.5 
        C 70,17 72,19 74,18.5 
        C 76,18 78,16 80,16.5 
        C 82,17 84,19 86,18.5 
        C 88,18 90,16 92,16.5 
        C 94,17 96,19 98,18.5 
        L 100,18"
        fill="none"
        stroke="#e0e0e0"
        stroke-width="0.5"
        stroke-linecap="round"
      />
    </svg>
  </div>
  <div class="ticket-content">
    <h2>Your Number</h2>
    <div class="number">{displayNumber ?? "No number"}</div>
    <button on:click={onRelinquish} class="relinquish-button">
      Relinquish Number
    </button>
  </div>
</div>

<style>
  .ticket {
    border-radius: 8px;
    overflow: visible;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
    position: relative;
    animation: slideIn 0.5s ease-out;
  }

  .torn-edge {
    height: 30px;
    margin-bottom: -10px;
    position: relative;
    filter: drop-shadow(0 -1px 2px rgba(0, 0, 0, 0.1));
  }

  .torn-edge::after {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 100%;
    background: linear-gradient(
      180deg,
      transparent 0%,
      rgba(0, 0, 0, 0.03) 100%
    );
    pointer-events: none;
  }

  .torn-edge svg {
    width: 100%;
    height: 100%;
  }

  .ticket-content {
    background: white;
    padding: 20px;
    border-radius: 0 0 8px 8px;
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

  .relinquish-button {
    padding: 12px 24px;
    font-size: 16px;
    background-color: #e74c3c;
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  }

  .relinquish-button:hover {
    background-color: #c0392b;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  .relinquish-button:active {
    transform: translateY(0);
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

  @media (max-width: 768px) {
    .number {
      font-size: 56px;
    }

    .relinquish-button {
      padding: 10px 20px;
      font-size: 14px;
    }
  }
</style>
