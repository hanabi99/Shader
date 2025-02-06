Shader "Unlit/MotionDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //用于控制模糊程度的 模糊偏移量
        _BlurSize("BlurSize", Float) = 0.5
    }
    SubShader
    {
        Pass
        {
            ZTest Always
            Cull Off
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_depth : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed _BlurSize;
            sampler2D _CameraDepthTexture;//深度纹理
            float4x4 _ClipToWorldMatrix;//裁剪空间到世界空间的变换矩阵
            float4x4 _FrontWorldToClipMatrix;//上一帧 世界空间到裁剪空间的变换矩阵

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;
                //多平台时建议进行判断
                #if UNITY_UV_STARTS_AT_TOP
                    if (_MainTex_TexelSize.y < 0)
                        o.uv_depth.y = 1 - o.uv_depth.y;
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //1.得到裁剪空间下的两个点
                //获取深度值
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                depth = Linear01Depth(depth);
                //裁剪空间下的一个组合坐标 把0~1范围变换到-1~1范围
                //第一个点
                float4 nowClipPos = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth , 1);
                //用裁剪空间到世界空间的变换矩阵 得到 世界空间下的带你
                float4 worldPos = mul(_ClipToWorldMatrix, nowClipPos);
                //透视除法
                worldPos /= worldPos.w;
                //利用上一帧的变换矩阵 得到上一帧 对应的裁剪空间下的点
                //第二个点
                float4 oldClipPos = mul(_FrontWorldToClipMatrix, worldPos);
                //透视除法
                oldClipPos /= oldClipPos.w;

                //2.得到运动方向
                float2 moveDir = (nowClipPos.xy - oldClipPos.xy)/2;

                //3.进行模糊处理
                float2 uv = i.uv;
                float4 color = float4(0,0,0,0);
                for (int it = 0; it < 3; it++)
                {
                    color += tex2D(_MainTex, uv);
                    uv += moveDir * _BlurSize;
                }
                //计算叠加3次后颜色的平均值 相当于就是在进行模糊处理了
                color /= 3;
                //返回模糊处理后的颜色
                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback Off
}