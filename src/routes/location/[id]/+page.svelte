<script>
  import { page } from '$app/stores';
  import NumberManager from '$lib/components/NumberManager.svelte';

  // Get the location ID from the URL parameters
  $: locationId = $page.params.id;
</script>

<div class="container">
  <h1>Take a Number</h1>
  <NumberManager {locationId} />
</div>

<style>
  .container {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
    text-align: center;
  }
</style> 