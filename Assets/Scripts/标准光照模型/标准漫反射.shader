Shader "Unlit/标准漫反射"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1)
        //主纹理
        _MainTex ("MainTex", 2D) = "white" { }
        //法线纹理
        _BumpMap ("BumpMap", 2D) = "" { }
        //凹凸程度
        _BumpScale ("BumpScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "Queue" = "Geometry"}
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _MainColor;
            sampler2D _BumpMap; //法线纹理
            float4 _BumpMap_ST; //法线纹理的缩放平移
            float _BumpScale; //凹凸程度

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                //切线到世界空间得变换矩阵
                float3x3 rotation : TEXCOORD2;
                SHADOW_COORDS(10)
            };

            v2f vert (appdata_full v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                //法线计算
                data.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                data.wpos = mul(unity_ObjectToWorld, v.vertex);
                float3 world_normal = UnityObjectToWorldNormal(v.normal.xyz);
                float3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 world_binormal = cross(normalize(world_normal), normalize(world_tangent)) * v.tangent.w;
                //切线到世界空间得变换矩阵
                data.rotation = float3x3(world_tangent.x, world_binormal.x, world_normal.x,
                                         world_tangent.y, world_binormal.y, world_normal.y,
                                         world_tangent.z, world_binormal.z, world_normal.z);
                TRANSFER_SHADOW(data);
               return data;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
                //取出法线数据采样
                float4 packNormal = tex2D(_BumpMap, i.uv.zw);
                //逆运算
                float3 tangentNormal = UnpackNormal(packNormal);

                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //将法线转换为世界空间
                float3 worldNormal = mul(i.rotation, tangentNormal);

                //纹理颜色需要与漫反射材质颜色相乘
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _MainColor.rgb;
                //兰伯特
                fixed3 lambertcolor = _LightColor0.rgb * albedo.rgb * max(0, dot(worldNormal, normalize(lightDir)));
                
                UNITY_LIGHT_ATTENUATION(atten,i,i.wpos)
                //bulinPhong
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertcolor * atten;
                return fixed4(blinnPhongColor.rgb, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd"}
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include  "AutoLight.cginc"

            sampler2D _MainTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _MainTex_ST;
            //材质漫反射颜色
            fixed4 _MainColor;
            sampler2D _BumpMap; //法线纹理
            float4 _BumpMap_ST; //法线纹理的缩放平移
            float _BumpScale; //凹凸程度

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 wpos : TEXCOORD1;
                //切线到世界空间得变换矩阵
                float3x3 rotation : TEXCOORD2;
                SHADOW_COORDS(10)
            };

            v2f vert (appdata_full v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                //法线计算
                data.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                data.wpos = mul(unity_ObjectToWorld, v.vertex);
                float3 world_normal = UnityObjectToWorldNormal(v.normal.xyz);
                float3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 world_binormal = cross(normalize(world_normal), normalize(world_tangent)) * v.tangent.w;
                //切线到世界空间得变换矩阵
                data.rotation = float3x3(world_tangent.x, world_binormal.x, world_normal.x,
                                         world_tangent.y, world_binormal.y, world_normal.y,
                                         world_tangent.z, world_binormal.z, world_normal.z);
                TRANSFER_SHADOW(data);
               return data;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //float3 viewDir = normalize(UnityWorldSpaceViewDir(i.wpos));
                //取出法线数据采样
                float4 packNormal = tex2D(_BumpMap, i.uv.zw);
                //逆运算
                float3 tangentNormal = UnpackNormal(packNormal);

                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //将法线转换为世界空间
                float3 worldNormal = mul(i.rotation, tangentNormal);

                //纹理颜色需要与漫反射材质颜色相乘
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _MainColor.rgb;
                //兰伯特
                fixed3 lambertcolor = _LightColor0.rgb * albedo.rgb * max(0, dot(worldNormal, normalize(lightDir)));
                
                UNITY_LIGHT_ATTENUATION(atten,i,i.wpos)
                //bulinPhong
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + lambertcolor * atten;
                return fixed4(blinnPhongColor.rgb, 1);
            }
            ENDCG
        }
    }
 Fallback "Diffuse"
}
