Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogColor("FogColor", Color) = (1,1,1,1)
        _FogDensity("FogDensity", Float) = 1
        _FogStart("FogStart", Float) = 0
        _FogEnd("FogEnd", Float) = 10
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            ZWrite Off
            Cull Off
            ZTest Always
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 depth_uv : TEXCOORD1;
                //顶点射线 指向四个角的方向向量 （传递到片元时 会自动进行插值 运算）
                float4 ray : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            //纹素 用来判断翻转会使用
            half4 _MainTex_TexelSize;
            //深度纹理
            sampler2D _CameraDepthTexture;
            //雾相关的属性
            fixed4 _FogColor;
            fixed _FogDensity;
            float _FogStart;
            float _FogEnd;
            //矩阵相关 里面存储了 4条射线向量
            //0-左下 1-右下 2-右上 3-左上
            float4x4 _RayMatrix;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.depth_uv = v.texcoord;
                int index = 0;
                //顶点着色器函数 每一个顶点都会执行一次
                //对于屏幕后处理来说 就会执行4次 因为有4个顶点 （4个角）
                //通过uv坐标判断 当前的顶点位置
                if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5)
                {
                    index = 0;
                }
                else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5)
                {
                    index = 1;
                }
                else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5)
                {
                    index = 2;
                }
                else
                {
                    index = 3;
                }
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                {
                    o.depth_uv.y = 1 - o.depth_uv.y;
                    index = 3 - index;
                }
                 #endif
                o.ray = _RayMatrix[index];
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //观察空间下像素到摄像机的距离
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.depth_uv));
                float3 worldPos = _WorldSpaceCameraPos + i.ray * linearDepth;
                //计算雾的强度
                float f = saturate((_FogEnd - worldPos.y) / (_FogEnd - _FogStart));
                f = saturate(f * _FogDensity);
                fixed3 col = lerp(tex2D(_MainTex, i.uv).rgb, _FogColor.rgb, f);
                return fixed4(col, 1);
            }
            ENDCG
        }
    }
}