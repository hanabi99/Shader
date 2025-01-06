Shader "Unlit/_ReflectBase"
{
    Properties
    {
       _Cube("CubeMap", Cube) = "" {}
       _Reflectivity("Reflectivity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
             #include "Lighting.cginc"

            samplerCUBE _Cube;
            float _Reflectivity;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 reflect : TEXCOORD0;
            };
            
            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 w_nomal = UnityObjectToWorldNormal(v.normal);
                float3 w_pos = mul(unity_ObjectToWorld,v.vertex);
                float3 view_dir = normalize(UnityWorldSpaceViewDir(w_pos));
                float3 w_reflect = reflect(-view_dir, w_nomal);
                o.reflect = w_reflect;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
              fixed4 cubemap =  texCUBE(_Cube, i.reflect);
              return cubemap * _Reflectivity;  
            }
            ENDCG
        }
    }
}
