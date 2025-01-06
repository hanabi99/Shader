Shader "Unlit/Reflect_漫反射"
{
    Properties
    {
        _Cube("CubeMap", Cube) = "" {}
        _Reflectivity("Reflectivity", Range(0, 1)) = 1
        _ReflectColor("ReflectColor", Color) = (1,1,1,1)
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "Queue"="Geometry"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            samplerCUBE _Cube;
            float _Reflectivity;
            fixed4 _Color;
            fixed4 _ReflectColor;


            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 reflect : TEXCOORD0;
                fixed3 w_normal : NORMAL;
                float3 w_pos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.w_normal = UnityObjectToWorldNormal(v.normal);
                o.w_pos = mul(unity_ObjectToWorld, v.vertex);
                float3 view_dir = normalize(UnityWorldSpaceViewDir(o.w_pos));
                float3 w_reflect = reflect(-view_dir, o.w_normal);
                o.reflect = w_reflect;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.w_pos).xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(normalize(i.w_normal), worldLightDir));
                fixed3 cubemap_color = texCUBE(_Cube, i.reflect).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.w_pos);
                //利用lerp 在漫反射颜色和反射颜色之间 进行插值 0和1就是极限状态 0 没有反射效果 1只有反射效果 0~1之间就是两者叠加
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb  + lerp(diffuse, cubemap_color, _Reflectivity) * atten;
                 return fixed4(color, 1.0);
            }
            ENDCG
        }
          Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            samplerCUBE _Cube;
            float _Reflectivity;
            fixed4 _Color;
            fixed4 _ReflectColor;


            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 reflect : TEXCOORD0;
                fixed3 w_normal : NORMAL;
                float3 w_pos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.w_normal = UnityObjectToWorldNormal(v.normal);
                o.w_pos = mul(unity_ObjectToWorld, v.vertex);
                float3 view_dir = normalize(UnityWorldSpaceViewDir(o.w_pos));
                float3 w_reflect = reflect(-view_dir, o.w_normal);
                o.reflect = w_reflect;
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.w_pos).xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(normalize(i.w_normal), worldLightDir));
                fixed3 cubemap_color = texCUBE(_Cube, i.reflect).rgb * _ReflectColor.rgb;
                UNITY_LIGHT_ATTENUATION(atten, i, i.w_pos);
                //利用lerp 在漫反射颜色和反射颜色之间 进行插值 0和1就是极限状态 0 没有反射效果 1只有反射效果 0~1之间就是两者叠加
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb  + lerp(diffuse, cubemap_color, _Reflectivity) * atten;
                 return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Reflective/VertexLit"
}