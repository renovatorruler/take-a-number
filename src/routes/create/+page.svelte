<script lang="ts">
    import { goto } from "$app/navigation";

    let locationName = "";
    let isSubmitting = false;
    let error = "";

    function generateGuid() {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(
            /[xy]/g,
            function (c) {
                const r = (Math.random() * 16) | 0;
                const v = c === "x" ? r : (r & 0x3) | 0x8;
                return v.toString(16);
            },
        );
    }

    async function handleSubmit() {
        if (!locationName.trim()) {
            error = "Please enter a location name";
            return;
        }

        isSubmitting = true;
        error = "";

        try {
            const locationId = generateGuid();
            // Navigate to the new location
            await goto(`/location/${locationId}`);
        } catch (e) {
            error = "Failed to create location";
            isSubmitting = false;
        }
    }
</script>

<div class="create-location">
    <h2>Create New Location</h2>

    <form on:submit|preventDefault={handleSubmit}>
        <div class="form-group">
            <label for="locationName">Location Name</label>
            <input
                type="text"
                id="locationName"
                bind:value={locationName}
                placeholder="Enter location name"
                disabled={isSubmitting}
            />
        </div>

        {#if error}
            <div class="error">{error}</div>
        {/if}

        <button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Creating..." : "Create Location"}
        </button>
    </form>
</div>

<style>
    .create-location {
        max-width: 400px;
        margin: 2rem auto;
        padding: 2rem;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    h2 {
        margin: 0 0 1.5rem;
        color: #2c3e50;
        text-align: center;
    }

    .form-group {
        margin-bottom: 1.5rem;
    }

    label {
        display: block;
        margin-bottom: 0.5rem;
        color: #2c3e50;
        font-weight: 500;
    }

    input {
        width: 100%;
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 1rem;
        box-sizing: border-box;
    }

    input:focus {
        outline: none;
        border-color: #3498db;
        box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
    }

    button {
        width: 100%;
        padding: 0.75rem;
        background: #3498db;
        color: white;
        border: none;
        border-radius: 4px;
        font-size: 1rem;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    button:hover:not(:disabled) {
        background: #2980b9;
    }

    button:disabled {
        background: #95a5a6;
        cursor: not-allowed;
    }

    .error {
        color: #e74c3c;
        margin-bottom: 1rem;
        text-align: center;
    }
</style>
