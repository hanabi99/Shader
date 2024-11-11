Shader "Unlit/Gradient_Normal"
{
    //渐变纹理
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
        //渐变纹理
        _RampTex ("RampTex", 2D) = "" {}
        //凹凸程度
        _BumpScale ("BumpScale", Range(0,1)) = 1
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
            sampler2D _RampTex;
            //纹理的缩放和偏移 x,y缩放 zw偏移
            float4 _RampTex_ST;
            
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 light_dir : TEXCOORD1;
                float3 view_dir : TEXCOORD2;
            };

            //得到Blinn Phong式高光反射模型计算的颜色（逐片元）
            fixed3 getSpecularColor(in float3 tNormal,float3 light_dir,float3 view_dir)
            {
                //1.视角单位向量
                float3 viewDir = normalize(view_dir);

                //2.光的反射单位向量
                //光的方向
                float3 lightDir = normalize(light_dir);

                //半角方向向量
                float3 halfA = normalize(viewDir + lightDir);
                
                //color = 光源颜色 * 材质高光反射颜色 * pow( max(0, dot(视角单位向量, 光的反射单位向量)), 光泽度 )
                fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow( max(0, dot(tNormal, halfA)), _SpecularNum);

                return color;
            }
            
            v2f vert (appdata_full v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                //法线计算
                data.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                //副切线 叉乘切线有两条 通过×切线中的w确定哪一条
                float3 binormal = cross(normalize(v.normal),normalize(v.tangent)) * v.tangent.w;
                //父到子
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
                //取出法线数据采样
                float4 packNormal = tex2D(_BumpMap, i.uv.zw);
                //逆运算
                float3 tangentNormal = UnpackNormal(packNormal);
                
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //纹理颜色需要与漫反射材质颜色相乘
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _MainColor.rgb;
                
                //半兰伯特后半部分
                fixed gradient = dot(normalize(tangentNormal),normalize(i.light_dir)) * 0.5 + 0.5;
                //计算渐变纹理颜色
                fixed3 RampColor = albedo.rgb * _LightColor0.rgb *  tex2D(_RampTex, fixed2(gradient,gradient)).rgb;
                //计算BlinnPhong式高光反射颜色
                fixed3 specularColor = getSpecularColor(tangentNormal, i.light_dir, i.view_dir);
                //物体表面光照颜色 = 环境光颜色 * albedo + 兰伯特光照模型所得颜色 + Phong式高光反射光照模型所得颜色
                fixed3 blinnPhongColor = (UNITY_LIGHTMODEL_AMBIENT.rgb * albedo) + RampColor + specularColor; 

                return fixed4(blinnPhongColor.rgb, 1);
            }
            ENDCG
        }
    }
}