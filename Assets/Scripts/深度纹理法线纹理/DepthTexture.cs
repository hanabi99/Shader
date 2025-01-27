using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTexture : PostEffectBase
{
    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}
