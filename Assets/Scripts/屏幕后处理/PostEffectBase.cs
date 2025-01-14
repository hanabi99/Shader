using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class PostEffectBase : MonoBehaviour
{
    private Shader m_Shader;
    
    //一个用于动态创建出来的材质球 就不用再工程中手动创建了
    private Material _material;

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Material != null)
            Graphics.Blit(source, destination, Material);
        else
            Graphics.Blit(source, destination);
    }

    private Material Material
    {
        get
        {
            //如果shader 没有 或者有但是不支持当前平台
            if (m_Shader == null || !m_Shader.isSupported)
                return null;
            else
            {
                if (_material != null && _material.shader == m_Shader)
                    return _material;
                //除非材质球是空的 或者shader变化了 才会走下面的逻辑

                //用支持的shader动态创建一个材质球 用于渲染
                _material = new Material(m_Shader)
                {
                    //不希望材质球被保存下来
                    hideFlags = HideFlags.DontSave
                };
                return _material;
            }
        }
    }
}
