using UnityEngine;

public class Edge : PostEffectBase
{
    public Color EdgeColor;
    public Color BackgroundColor;
    [Range(0, 1)] public float BackgroundExtent;

    protected override void UpdateProperty()
    {
        if (material != null)
        {
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetColor("_BackGroundColor", BackgroundColor);
            material.SetFloat("_BackGroundToMainTexLerp", BackgroundExtent);
        }
    }
}
