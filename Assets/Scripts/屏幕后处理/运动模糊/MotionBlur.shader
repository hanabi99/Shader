Shader "Unlit/MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //模糊程度变量
        _BlurAmount("BlurAmount", Float) = 0.5
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        fixed _BlurAmount;

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        v2f vert(appdata_base v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        ENDCG

        //屏幕后处理效果标配
        ZTest Always
        Cull Off
        ZWrite Off

        //第一个Pass 用于混合RGB通道
        Pass
        {
            //（(源颜色 * _BlurAmount) + (目标颜色 * (1 - _BlurAmount))）
            Blend SrcAlpha OneMinusSrcAlpha
            //（只改变颜色缓冲区中的RGB通道）
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB

            fixed4 fragRGB(v2f i) : SV_Target
            {
                return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
            }
            ENDCG
        }

        Pass
        {
            //（最终颜色 = (源颜色 * 1) + (目标颜色 * 0)）
            Blend One Zero
            //（只改变颜色缓冲区中的A通道）
            ColorMask A

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA

            fixed4 fragA(v2f i) : SV_Target
            {
                return fixed4(tex2D(_MainTex, i.uv));
            }
            ENDCG
        }
    }
    Fallback Off
}
