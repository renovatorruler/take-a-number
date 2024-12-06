<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  // Hard-coded location GUID - you can replace this with your desired GUID
  const DEFAULT_LOCATION = "550e8400-e29b-41d4-a716-446655440000";

  onMount(() => {
    // Redirect to the default location
    goto(`/location/${DEFAULT_LOCATION}`);
  });
</script>

<div class="container">
  <h1>Redirecting...</h1>
</div>

<style>
  .container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    text-align: center;
  }
</style>