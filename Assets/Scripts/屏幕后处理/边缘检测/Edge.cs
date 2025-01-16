using UnityEngine;

public class Edge : PostEffectBase
{
    public Color EdgeColor;

    protected override void UpdateProperty() 
    {
        if(material != null)
        {
            material.SetColor("_EdgeColor", EdgeColor);
        }
    }
}
