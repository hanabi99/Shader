Shader "Unlit/Occlusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha", Range(0,1)) = 0.5
        _Color("Color", Color) = (1,1,1,1)
        _FresnelScale("FresnelScale", Range(0,1)) = 1
        _FresnelN("FresnelN" , Float) = 5
        
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Greater
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 w_nomal : NORMAL;
                float3 view_dir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Alpha;
            float _FresnelScale;
            float _FresnelN;
            fixed4 _Color;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.w_nomal = normalize(UnityObjectToWorldNormal(v.normal));
                float4 w_pos = mul(unity_ObjectToWorld, v.vertex);
                //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置 
                o.view_dir = normalize(UnityWorldSpaceViewDir(w_pos));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //利用schlick菲涅耳近似等式 计算菲涅耳反射率
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normalize(i.view_dir), normalize(i.w_nomal)), _FresnelN);
                return fixed4(_Color.rgb,fresnel);
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}