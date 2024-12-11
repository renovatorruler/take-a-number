<script>
  import { goto } from "$app/navigation";

  // Hard-coded location GUID - you can replace this with your desired GUID
  const DEFAULT_LOCATION = "550e8400-e29b-41d4-a716-446655440000";

  function goToDefaultLocation() {
    goto(`/location/${DEFAULT_LOCATION}`);
  }

  function createNewLocation() {
    goto("/create");
  }
</script>

<div class="container">
  <h1>Welcome to Take a Number</h1>
  <p>Choose an option to get started:</p>

  <div class="button-group">
    <button class="primary" on:click={createNewLocation}>
      Create New Location
    </button>
    <button class="secondary" on:click={goToDefaultLocation}>
      Go to Demo Location
    </button>
  </div>
</div>

<style>
  .container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    text-align: center;
  }

  h1 {
    color: #2c3e50;
    margin-bottom: 1rem;
  }

  p {
    color: #34495e;
    margin-bottom: 2rem;
  }

  .button-group {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    max-width: 300px;
    margin: 0 auto;
  }

  button {
    padding: 1rem;
    border: none;
    border-radius: 4px;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .primary {
    background: #3498db;
    color: white;
  }

  .primary:hover {
    background: #2980b9;
    transform: translateY(-2px);
  }

  .secondary {
    background: #ecf0f1;
    color: #2c3e50;
  }

  .secondary:hover {
    background: #bdc3c7;
    transform: translateY(-2px);
  }
</style>
