using UnityEngine;
public class MotionDepth : PostEffectBase
{
    [Range(0,1)]
    public float blurSize = 0.5f;
    //用于记录上一次的变换矩阵的变量
    private Matrix4x4 frontWorldToClipMatrix;

    private void Start()
    {
        //开启深度纹理
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        //初始化上一次的变换矩阵 用 观察到裁剪变换矩阵（摄像机的透视矩阵） * 世界到观察变换矩阵
        //得到的 就是 世界空间到裁剪空间的变换矩阵
        //frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
    }

    private void OnEnable()
    {
        //有时我们会在界面上让脚本失活，每次激活时 可以初始化一次
        frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
    }

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            //设置模糊程度
            material.SetFloat("_BlurSize", blurSize);
            //设置上一帧世界空间到裁剪空间的矩阵
            material.SetMatrix("_FrontWorldToClipMatrix", frontWorldToClipMatrix);
            //计算这一帧的变换矩阵
            frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
            //设置这一帧的 裁剪到世界空间的变换矩阵
            material.SetMatrix("_ClipToWorldMatrix", frontWorldToClipMatrix.inverse);
            //进行屏幕后期处理
            Graphics.Blit(source, destination, material); 
        }
        else
            Graphics.Blit(source, destination);
    }
}
