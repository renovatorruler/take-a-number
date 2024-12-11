import { derived } from 'svelte/store';

export const unboxStore = (store) => {
    return derived(store, $value => {
        if ($value === null || $value === undefined) return null;
        // Handle NumberValue type from ReScript
        const n = $value[0]; // Access the value inside NumberValue
        return n !== undefined ? { _0: n } : null;
    });
}