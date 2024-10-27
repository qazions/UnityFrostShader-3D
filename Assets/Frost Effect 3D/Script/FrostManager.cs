using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FrostManager : MonoBehaviour
{
    [Header("Freeze Settings")]
    [SerializeField, Range(0, 1)] private float freezeSpeed = 0.1f; // Speed at which freezing occurs

    [Header("Ice Particle System")]
    [SerializeField] private ParticleSystem iceParticleSystem; // Reference to the ice particle system

    [Header("Character Materials")]
    [SerializeField] private List<Material> characterMaterials; // List of materials to freeze/unfreeze

    private Coroutine frostCoroutine;

    private void Start()
    {
        // Ensure particle system is stopped initially
        if (iceParticleSystem != null)
        {
            iceParticleSystem.Stop();
        }

        // Initialize materials to default values
        InitializeMaterials();
    }

    private void InitializeMaterials()
    {
        foreach (var material in characterMaterials)
        {
            material.SetFloat("_FrostAmount", 0f); // Start with no freeze
        }
    }

    // Call to gradually freeze the character
    public void Freeze()
    {
        // Stop any running frost effect to prevent conflict
        if (frostCoroutine != null)
        {
            StopCoroutine(frostCoroutine);
        }
        frostCoroutine = StartCoroutine(FrostEffectCoroutine(1f)); // Target full freeze
    }

    // Call to gradually unfreeze the character
    public void Unfreeze()
    {
        // Stop any running frost effect to prevent conflict
        if (frostCoroutine != null)
        {
            StopCoroutine(frostCoroutine);
        }
        frostCoroutine = StartCoroutine(FrostEffectCoroutine(0f)); // Target no freeze
    }

    private IEnumerator FrostEffectCoroutine(float targetFreezeAmount)
    {
        // Get current freeze amount from the first material
        float currentFreezeAmount = characterMaterials[0].GetFloat("_FrostAmount");

        // Gradually move towards the target freeze amount
        while (!Mathf.Approximately(currentFreezeAmount, targetFreezeAmount))
        {
            currentFreezeAmount = Mathf.MoveTowards(currentFreezeAmount, targetFreezeAmount, freezeSpeed * Time.deltaTime);

            // Control the ice particle system based on freeze amount
            if (currentFreezeAmount >= 0.5f)
            {
                if (!iceParticleSystem.isPlaying) // Check if the particle system is not already playing
                {
                    iceParticleSystem.Play(); // Activate particles
                }
            }
            else
            {
                if (iceParticleSystem.isPlaying) // Check if the particle system is currently playing
                {
                    iceParticleSystem.Stop(); // Deactivate particles
                }
            }

            // Update all materials' freeze amounts
            foreach (var material in characterMaterials)
            {
                material.SetFloat("_FrostAmount", currentFreezeAmount); // Adjust according to shader's freeze property
            }

            yield return null; // Wait for the next frame
        }

        // Final update to ensure the target value is set
        foreach (var material in characterMaterials)
        {
            material.SetFloat("_FrostAmount", targetFreezeAmount); // Set the final target freeze amount
        }

        // Stop or start the particle system depending on the final state
        if (targetFreezeAmount < 0.5f && iceParticleSystem.isPlaying)
        {
            iceParticleSystem.Stop(); // Deactivate particles if target is below 0.5
        }
        else if (targetFreezeAmount >= 0.5f && !iceParticleSystem.isPlaying)
        {
            iceParticleSystem.Play(); // Activate particles if target is 0.5 or higher
        }
    }
}
