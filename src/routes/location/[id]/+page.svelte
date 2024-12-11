<script>
  import { page } from "$app/stores";
  import NumberManager from "$lib/components/NumberManager.svelte";

  $: locationId = $page.params.id;
  $: console.log("Page locationId:", locationId);
</script>

<div class="container">
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
