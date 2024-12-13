<script lang="ts">
    import { make } from "@res/lib/components/LocationManager.mjs";
    const { state, handleDelete, goToLocation, formatDate } = make();
</script>

<div class="manage-locations">
    <h2>Manage Locations</h2>

    {#if $state.isLoading}
        <div class="loading">Loading...</div>
    {:else if $state.locations.length === 0}
        <div class="empty-state">
            <p>You haven't created any locations yet.</p>
            <a href="/create" class="create-button"
                >Create Your First Location</a
            >
        </div>
    {:else}
        <div class="locations-grid">
            {#each $state.locations as location (location.id)}
                <div class="location-card">
                    <h3>{location.name}</h3>
                    <p class="date">
                        Created: {formatDate(location.createdAt)}
                    </p>
                    <div class="actions">
                        <button
                            class="view-button"
                            on:click={() => goToLocation(location.id)}
                        >
                            View
                        </button>
                        <button
                            class="delete-button"
                            on:click={() => handleDelete(location.id)}
                        >
                            Delete
                        </button>
                    </div>
                </div>
            {/each}
        </div>
    {/if}
</div>

<style>
    .manage-locations {
        max-width: 800px;
        margin: 0 auto;
        padding: 2rem;
    }

    .loading,
    .empty-state {
        text-align: center;
        padding: 2rem;
    }

    .locations-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 1.5rem;
    }

    .location-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .actions {
        display: flex;
        gap: 0.5rem;
        margin-top: 1rem;
    }

    button {
        flex: 1;
        padding: 0.5rem;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }

    .view-button {
        background: #3498db;
        color: white;
    }

    .delete-button {
        background: #e74c3c;
        color: white;
    }

    .create-button {
        display: inline-block;
        padding: 0.75rem 1.5rem;
        background: #3498db;
        color: white;
        text-decoration: none;
        border-radius: 4px;
    }
</style>
