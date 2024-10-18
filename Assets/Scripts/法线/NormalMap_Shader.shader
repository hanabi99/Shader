Shader "Unlit/NormalMap_Shader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //主纹理
        _MainTex ("MainTex", 2D) = "white" { }
        //高光反射材质颜色
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //光泽度
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //法线纹理
        _BumpMap ("BumpMap", 2D) = "" { }
        //凹凸程度
        _BumpScale ("BumpScale", Float) = 1
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularNum;
            sampler2D _BumpMap; //法线纹理
            float4 _BumpMap_ST; //法线纹理的缩放平移
            float _BumpScale; //凹凸程度
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 light_dir : TEXCOORD1;
                float3 view_dir : TEXCOORD2;
            };
            
            v2f vert (appdata_full v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                //采样法线纹理
                data.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                //副切线
                float3 binormal = cross(v.normal, v.tangent) * v.tangent.w;
                float3x3 rotation = float3x3(
                    v.tangent.xyz
                    , binormal
                    , v.normal);
                data.light_dir = mul(ObjSpaceLightDir(v.vertex),rotation);
                data.view_dir = mul(ObjSpaceViewDir(v.vertex),rotation);
                return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
