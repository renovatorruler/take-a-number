<script lang="ts">
    import { make } from "@res/lib/components/LocationCreator.mjs";
    const { state, handleSubmit } = make();
</script>

<div class="create-location">
    <h2>Create New Location</h2>

    <form on:submit|preventDefault={handleSubmit}>
        <div class="form-group">
            <label for="locationName">Location Name</label>
            <input
                type="text"
                id="locationName"
                bind:value={$state.locationName}
                placeholder="Enter location name"
                disabled={$state.isSubmitting}
            />
        </div>

        {#if $state.error}
            <div class="error">{$state.error}</div>
        {/if}

        <button type="submit" disabled={$state.isSubmitting}>
            {$state.isSubmitting ? "Creating..." : "Create Location"}
        </button>
    </form>
</div>

<style>
    .create-location {
        max-width: 600px;
        margin: 0 auto;
        padding: 2rem;
    }

    .form-group {
        margin-bottom: 1.5rem;
    }

    label {
        display: block;
        margin-bottom: 0.5rem;
        color: #2c3e50;
    }

    input {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 1rem;
    }

    .error {
        color: #e74c3c;
        margin: 1rem 0;
    }

    button {
        width: 100%;
        padding: 1rem;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        cursor: pointer;
    }

    button:disabled {
        background: #95a5a6;
        cursor: not-allowed;
    }
</style>
