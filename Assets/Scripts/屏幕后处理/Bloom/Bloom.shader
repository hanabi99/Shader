Shader "Unlit/_Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //用于存储亮度纹理模糊后的结果
        _Bloom("Bloom", 2D) = ""{}
        //亮度阈值 控制亮度纹理 亮度区域的
        _LuminanceThreshold("LuminanceThreshold", Float) = 0.5
        //模糊半径
        _BlurRadius("BlurRadius", Float) = 1
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BloomRadius;

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        //计算颜色的亮度值（灰度值）
        fixed luminance(fixed4 color)
        {
            return 0.2125*color.r + 0.7154*color.g + 0.0721*color.b;
        }

        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off
        //提取的Pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(appdata_base v){
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                //采样源纹理颜色
                fixed4 color = tex2D(_MainTex, i.uv);
                //得到亮度贡献值
                fixed value = clamp(Luminance(color) - _LuminanceThreshold, 0, 1);
                //返回颜色*亮度贡献值
                return color * value;
            }

            ENDCG
        }
        //复用高斯模糊
        UsePass "Unlit/高斯Base/GAUSSIAN_BLUR_HORIZONTAL"
        UsePass "Unlit/高斯Base/GAUSSIAN_BLUR_VERTICAL"
    }
}
