Shader "Unlit/菲涅尔漫反射"
{
   Properties
   {
       //漫反射颜色
       _Color("Color", Color) = (1,1,1,1)
       _Cube("CubeMap", Cube) = "" {}
       //菲涅耳反射中 对应介质的反射率
       _FresnelScale("FresnelScale", Range(0,1)) = 1
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
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            samplerCUBE _Cube;
            float _FresnelScale;
            fixed4 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 w_nomal : NORMAL;
                float3 view_dir : TEXCOORD0;
                float3 w_pos : TEXCOORD1;
                float3 reflect : TEXCOORD2;
                SHADOW_COORDS(3)
            };
            
            v2f vert (appdata_base v)
            {
               v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算反射光向量
                //1.计算世界空间下法线向量
                o.w_nomal = UnityObjectToWorldNormal(v.normal);
                //2.世界空间下的顶点坐标
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置 
                o.view_dir = UnityWorldSpaceViewDir(o.w_pos);
                //4.计算反射向量
                o.reflect = reflect(-o.view_dir, o.w_nomal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 w_lightDir = normalize(_WorldSpaceLightPos0.xyz - i.w_pos);
                fixed3 diffuse = _LightColor0 * _Color.rgb * max(0, dot(normalize(i.w_nomal), normalize(w_lightDir)));
                fixed3 cubemap = texCUBE(_Cube, i.reflect).rgb;
                //得到光照衰减以及阴影相关的衰减值
                UNITY_LIGHT_ATTENUATION(atten, i, i.w_pos);
                //利用schlick菲涅耳近似等式 计算菲涅耳反射率
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normalize(i.view_dir), normalize(i.w_nomal)), 5);
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuse,cubemap, fresnel) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }

        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            samplerCUBE _Cube;
            float _FresnelScale;
            fixed4 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 w_nomal : NORMAL;
                float3 view_dir : TEXCOORD0;
                float3 w_pos : TEXCOORD1;
                float3 reflect : TEXCOORD2;
                SHADOW_COORDS(3)
            };
            
            v2f vert (appdata_base v)
            {
               v2f o;
                //顶点坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                //计算反射光向量
                //1.计算世界空间下法线向量
                o.w_nomal = UnityObjectToWorldNormal(v.normal);
                //2.世界空间下的顶点坐标
                o.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置 
                o.view_dir = UnityWorldSpaceViewDir(o.w_pos);
                //4.计算反射向量
                o.reflect = reflect(-o.view_dir, o.w_nomal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 w_lightDir = normalize(_WorldSpaceLightPos0.xyz - i.w_pos);
                fixed3 diffuse = _LightColor0 * _Color.rgb * max(0, dot(normalize(i.w_nomal), normalize(w_lightDir)));
                fixed3 cubemap = texCUBE(_Cube, i.reflect).rgb;
                //得到光照衰减以及阴影相关的衰减值
                UNITY_LIGHT_ATTENUATION(atten, i, i.w_pos);
                //利用schlick菲涅耳近似等式 计算菲涅耳反射率
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(normalize(i.view_dir), normalize(i.w_nomal)), 5);
                fixed3 color = lerp(diffuse,cubemap, fresnel) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
   FallBack "Reflective/VertexLit"
}
