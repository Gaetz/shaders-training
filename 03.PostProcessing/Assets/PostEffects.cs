using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class PostEffects : MonoBehaviour
{

    public Shader currentShader;
    private Material currentMaterial;
    public bool InvertEffect;
    public bool DepthEffect;
    Material material
    {
        get
        {
            if (currentMaterial == null)
            {
                currentMaterial = new Material(currentShader);
                currentMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return currentMaterial;
        }
    }

    void Start()
    {
        currentShader = Shader.Find("Hidden/PostEffects");
        GetComponent<Camera>().allowHDR = true;
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            Debug.Log("Image effect not supported");
            return;
        }
        if (!currentShader && !currentShader.isSupported)
        {
            enabled = false;
            Debug.Log("Shader not supported");
        }
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    }

    void Update()
    {
        if (!GetComponent<Camera>().enabled)
        {
            return;
        }
    }

    void OnDisable()
    {
        if (currentMaterial)
        {
            DestroyImmediate(currentMaterial);
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (InvertEffect)
        {
            Graphics.Blit(sourceTexture, destTexture, material, 0);
        }
        else if (DepthEffect)
        {
            Graphics.Blit(sourceTexture, destTexture, material, 1);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }


}
