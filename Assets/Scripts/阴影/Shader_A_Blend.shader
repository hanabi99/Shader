Shader "Unlit/Shader_A_Blend"
{
   Properties {
        _Color("MainColor", Color) = (1,1,1,1)
        //主纹理
        _MainTex ("MainTex", 2D) = "white" { }
        //高光反射材质颜色
        _SpecularColor ("_SpecularColor", Color) = (1, 1, 1, 1)
        //光泽度
        _SpecularNum ("_Glossiness", Range(0, 20)) = 0.5
        //透明度
        _Cutoff("_Cutoff", Range(0,1)) = 1
    }

    //单张纹理结合BuilnPhong光照模型
    SubShader {
         Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparept"}
        Pass {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _SpecularNum;
            fixed _Cutoff;


            struct v2f {
                float4 pos : SV_POSITION;
                half2  uv : TEXCOORD0;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD1;
            };
         
            fixed3 getLambertFColor(in float3 wNormal,fixed3 NewMainColor)
            {
                //得到光源单位向量
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算除了兰伯特光照的漫反射颜色
                fixed3 color = _LightColor0.rgb * NewMainColor.rgb * max(0, dot(wNormal, lightDir));

                return color;
            }

            
            fixed3 getSpecularColor(in float3 wPos, in float3 wNormal)
            {
                //1.视角单位向量
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );

                //2.光的反射单位向量
                //光的方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //半角方向向量
                float3 halfA = normalize(viewDir + lightDir);
                
                //color = 光源颜色 * 材质高光反射颜色 * pow( max(0, dot(视角单位向量, 光的反射单位向量)), 光泽度 )
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(wNormal, halfA)), _SpecularNum );

                return color;
            }

            v2f vert(appdata_base v) {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                //先缩放后平移
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //TRANSFORM_TEX(v.texcoord.xy, _MainTex); 相同的操作
                //v.texcoord.zw; //深度值等等
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                //顶点转到世界空间
                data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return data;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //纹理颜色需要与漫反射材质颜色相乘
                fixed3 albedo = texColor.rgb * _Color;
                //计算兰伯特光照颜色
                fixed3 lambertColor = getLambertFColor(i.wNormal,albedo);
                //计算BlinnPhong式高光反射颜色
                fixed3 specularColor = getSpecularColor(i.wPos, i.wNormal);
                //物体表面光照颜色 = 环境光颜色 * albedo + 兰伯特光照模型所得颜色 + Phong式高光反射光照模型所得颜色
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertColor + specularColor; 

                return fixed4(blinnPhongColor.rgb, texColor.a * _Cutoff);
            }
               ENDCG
        }
        Pass {
            Tags { "LightMode"="ForwardBase" }
            ZWrite Off
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _Color;
            fixed4 _SpecularColor;
            float _SpecularNum;
            fixed _Cutoff;


            struct v2f {
                float4 pos : SV_POSITION;
                half2  uv : TEXCOORD0;
                float3 wNormal : NORMAL;
                float3 wPos : TEXCOORD1;
            };
         
            fixed3 getLambertFColor(in float3 wNormal,fixed3 NewMainColor)
            {
                //得到光源单位向量
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //计算除了兰伯特光照的漫反射颜色
                fixed3 color = _LightColor0.rgb * NewMainColor.rgb * max(0, dot(wNormal, lightDir));

                return color;
            }

            
            fixed3 getSpecularColor(in float3 wPos, in float3 wNormal)
            {
                //1.视角单位向量
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );

                //2.光的反射单位向量
                //光的方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //半角方向向量
                float3 halfA = normalize(viewDir + lightDir);
                
                //color = 光源颜色 * 材质高光反射颜色 * pow( max(0, dot(视角单位向量, 光的反射单位向量)), 光泽度 )
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(wNormal, halfA)), _SpecularNum );

                return color;
            }

            v2f vert(appdata_base v) {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                //先缩放后平移
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //TRANSFORM_TEX(v.texcoord.xy, _MainTex); 相同的操作
                //v.texcoord.zw; //深度值等等
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                //顶点转到世界空间
                data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return data;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                //纹理颜色需要与漫反射材质颜色相乘
                fixed3 albedo = texColor.rgb * _Color;
                //计算兰伯特光照颜色
                fixed3 lambertColor = getLambertFColor(i.wNormal,albedo);
                //计算BlinnPhong式高光反射颜色
                fixed3 specularColor = getSpecularColor(i.wPos, i.wNormal);
                //物体表面光照颜色 = 环境光颜色 * albedo + 兰伯特光照模型所得颜色 + Phong式高光反射光照模型所得颜色
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertColor + specularColor; 

                return fixed4(blinnPhongColor.rgb, texColor.a * _Cutoff);
            }
                ENDCG
         }
   }
Fallback "VertexLit"
}
