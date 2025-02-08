Shader "Unlit/EageDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //用于控制自定义背景颜色程度的 0要显示原始背景色 1只显示边缘 完全显示自定义背景色
        _EdgeOnly("EdgeOnly", Float) = 0
        //边缘的描边颜色
        _EdgeColor("EdgeColor", Color) = (0,0,0,0)
        //自定义背景颜色
        _BackgroundColor("BackgroundColor", Color) = (1,1,1,1)
        //采样偏移程度 主要用来控制描边的粗细 值越大越粗 反之越细
        _SampleDistance("SampleDistance", Float) = 1
        //深度和法线的敏感度 用来进行这个差值判断时 起作用
        _SensitivityDepth("SensitivityDepth", Float) = 1
        _SensitivityNormal("SensitivityNormal", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
            #pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            //纹素 用于进行uv坐标偏移 取得周围像素的uv坐标的
            half4 _MainTex_TexelSize;
            //深度+法线纹理
            sampler2D _CameraDepthNormalsTexture;
            //用于控制自定义背景颜色程度的 0要显示原始背景色 1只显示边缘 完全显示自定义背景色
            fixed _EdgeOnly;
            //边缘的描边颜色
            fixed4 _EdgeColor;
            //自定义背景颜色
            fixed4 _BackgroundColor;
            //采样偏移程度 主要用来控制描边的粗细 值越大越粗 反之越细
            float _SampleDistance;
            //深度和法线的敏感度 用来进行这个差值判断时 起作用
            float _SensitivityDepth;
            float _SensitivityNormal;


            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            half CheckSame(half4 depthNormal1, half4 depthNormal2)
            {
                float depth1 = DecodeFloatRG(depthNormal1.zw);
                float2 normal1 = DecodeViewNormalStereo(depthNormal1).xy;
                float depth2 = DecodeFloatRG(depthNormal2.zw);
                float2 normal2 = DecodeViewNormalStereo(depthNormal2).xy;
                //法线的差异计算
                //计算两条法线的xy的差值 并且乘以 自定义的敏感度
                float2 normalDiff = abs(normal1 - normal2) * _SensitivityNormal;
                //判断两个法线是否在一个平面
                //如果差异不大 证明基本上在一个平面上 返回 1；否则返回0
                int isSameNormal = (normalDiff.x + normalDiff.y) < 0.1;
                //深度同理
                float DepthDifference = abs(depth1 - depth2)  * _SensitivityDepth;
                int isDepthSame = DepthDifference < 0.1 * depth1;
                
                return isSameNormal * isDepthSame ? 1 : 0;
            }

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half uv = v.texcoord;
                o.uv[0] = uv;
                //left top
                o.uv[1] = uv + v.texcoord.xy * half2(-1, 1) * _SampleDistance;
                //right bottom
                o.uv[2] = uv + v.texcoord.xy * half2(1, -1) * _SampleDistance;
                //right top
                o.uv[3] = uv + v.texcoord.xy * half2(1, 1) * _SampleDistance;
                //left bottom
                o.uv[4] = uv + v.texcoord.xy * half2(-1, -1) * _SampleDistance;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 TL = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                half4 BR = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                half4 TR = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                half4 BL = tex2D(_CameraDepthNormalsTexture, i.uv[4]);
                half isSame = 1;
                isSame *= CheckSame(TL, BR);
                isSame *= CheckSame(TR, BL);
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex,i.uv[0]),isSame);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, isSame);
                fixed4 withEdgeOnly = lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);

                return withEdgeOnly;
            }
            ENDCG
        }
    }
}