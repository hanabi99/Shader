Shader "Unlit/lightAttenuation"
{
    Properties
    {
        main_color("main_color", Color) = (1,1,1,1)
        //高光反射颜色  光泽度
        specular_color("specular_color", Color) = (1,1,1,1)
        specular_num("specular_num", Range(0, 20)) = 1
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma mutli_compile_fwdbase
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //材质漫反射颜色
            fixed4 main_color;
            fixed4 specular_color;
            float specular_num;

            //顶点着色器返回出去的内容
            struct v2_f
            {
                float4 pos:SV_POSITION;
                float3 w_normal:NORMAL;
                float3 w_pos:TEXCOORD0;
            };
            
            fixed3 get_lambert_f_color(in float3 wNormal)
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = _LightColor0.rgb * main_color.rgb * max(0, dot(wNormal, lightDir));

                return color;
            }
            
            fixed3 get_specular_color(in float3 wPos, in float3 wNormal)
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - wPos );
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfA = normalize(viewDir + lightDir);
                //color = 光源颜色 * 材质高光反射颜色 * pow( max(0, dot(视角单位向量, 光的反射单位向量)), 光泽度)
                fixed3 color = _LightColor0.rgb * specular_color.rgb * pow( max(0, dot(wNormal, halfA)), specular_num );

                return color;
            }

            v2_f vert (appdata_base v)
            {
                 v2_f v2fData;
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                v2fData.w_normal = UnityObjectToWorldNormal(v.normal);
                v2fData.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return v2fData;
            }

            fixed4 frag (v2_f i) : SV_Target
            {
                //计算兰伯特光照颜色
                fixed3 lambert_color = get_lambert_f_color(i.w_normal);
                //计算BlinnPhong式高光反射颜色
                fixed3 specular_color = get_specular_color(i.w_pos, i.w_normal);
                fixed3 blinnPhongColor = UNITY_LIGHTMODEL_AMBIENT.rgb + lambert_color + specular_color; 

                return fixed4(blinnPhongColor.rgb, 1);
            }
            ENDCG
        } 
        Pass
        {
            Tags { "LightMode"="ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            //材质漫反射颜色
            fixed4 main_color;
            fixed4 specular_color;
            float specular_num;

            //顶点着色器返回出去的内容
            struct v2_f
            {
                float4 pos:SV_POSITION;
                float3 w_normal:NORMAL;
                float3 w_pos:TEXCOORD0;
            };

            v2_f vert (appdata_base v)
            {
                 v2_f v2fData;
                v2fData.pos = UnityObjectToClipPos(v.vertex);
                v2fData.w_normal = UnityObjectToWorldNormal(v.normal);
                v2fData.w_pos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return v2fData;
            }

            fixed4 frag (v2_f i) : SV_Target
            {
                //计算兰伯特光照颜色
                fixed3 world_normal = normalize(i.w_normal);
                #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 word_light_dir = normalize(_WorldSpaceLightPos0.xyz);
                #else //点光源,聚光灯
                fixed3 word_light_dir = normalize(_WorldSpaceLightPos0.xyz - i.w_pos);
                #endif
                fixed3 lambert_color = _LightColor0.rgb * main_color.rgb * max(0,dot(world_normal,word_light_dir));
                
                //计算BlinnPhong式高光反射颜色
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.w_pos.xyz);
                float3 halfA = normalize(viewDir + word_light_dir);
                fixed3 specular = _LightColor0.rgb * specular_color.rgb * pow(max(0, dot(world_normal, halfA)), specular_num);
                
                //衰减值
                #ifdef USING_DIRECTIONAL_LIGHT
                     fixed attenuation = 1;
                #elif defined (POINT)
                    //世界空间转光源空间
                    float3 lightcoord = mul(unity_WorldToLight, float4(i.w_pos, 1)).xyz;
                    fixed attenuation = tex2D(_LightTexture0,dot(lightcoord,lightcoord).xx).UNITY_ATTEN_CHANNEL;
                #elif defined (SPOT)
                    //世界空间转光源空间
                    float4 lightCoord = mul(unity_WorldToLight, float4(i.w_pos, 1));
                    fixed attenuation = (lightCoord.z > 0) * //判断在聚光灯前面吗
                                  tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * //映射到大图中进行采样
                                  tex2D(_LightTextureB0, dot(lightCoord,lightCoord).xx).UNITY_ATTEN_CHANNEL; //距离的平方采样
                #else
                     fixed attenuation = 1;
                #endif

                return fixed4((lambert_color + specular) * attenuation, 1);
            }
            ENDCG
        }
    }
}
