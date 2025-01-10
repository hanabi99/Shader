Shader "Unlit/GlassNormal"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Cube("CubeMap", Cube) = "" {}
        //0 完全反射  1完全折射(直接透过去了)
        _RefractAmount("RefractAmount", Range(0, 1)) = 1
        //法线纹理
        _BumpMap ("BumpMap", 2D) = "" { }
        _Distortion("Distortion", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags{"RenderType"="Opaque" "Queue"="Transparent"}
        //捕获屏幕当前内容
        GrabPass{}

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _Cube;
            float _RefractAmount;
            //抓取的目的就是映射他里面罩着的东西纹理数据
            sampler2D _GrabTexture;
            sampler2D _BumpMap; //法线纹理
            float4 _BumpMap_ST; //法线纹理的缩放平移
            float _Distortion;

            struct v2f
            {
                float4 pos : SV_POSITION;
                //float3 reflect : TEXCOORD0;
                float3 wpos : TEXCOORD0;
                //抓取屏幕的位置
                float4 grabPos : TEXCOORD1;
                float4 uv : TEXCOORD2;
                float3x3 rotation : TEXCOORD3;
            };
            
            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv.xy = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                
                //float3 w_normal = UnityObjectToWorldNormal(v.normal);
                //float3 w_pos = mul(unity_ObjectToWorld,v.vertex);
                //float3 view_dir = normalize(UnityWorldSpaceViewDir(w_pos));
                //float3 w_reflect = reflect(-view_dir, w_normal);
                //o.reflect = w_reflect;
                o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord.xy, _BumpMap);
                float3 world_normal = UnityObjectToWorldNormal(v.normal.xyz);
                float3 world_tangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 world_binormal = cross(normalize(world_normal), normalize(world_tangent)) * v.tangent.w;
                //切线到世界空间得变换矩阵
                o.rotation = float3x3(world_tangent.x, world_binormal.x, world_normal.x,
                                         world_tangent.y, world_binormal.y, world_normal.y,
                                         world_tangent.z, world_binormal.z, world_normal.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //取出法线数据采样
                float4 packNormal = tex2D(_BumpMap, i.uv.zw);
                //逆运算
                float3 tangentNormal = UnpackNormal(packNormal);
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                 //将法线转换为世界空间
                float3 worldNormal = mul(i.rotation, tangentNormal);
                float3 view_dir = normalize(UnityWorldSpaceViewDir(i.wpos.xyz));
                float3 w_reflect = reflect(-view_dir, worldNormal);
                //主纹理采样
                fixed4 maintex = tex2D(_MainTex, i.uv.xy);
                fixed4 reflectColor = texCUBE(_Cube, w_reflect) * maintex;
                //凹凸折射自定义规则 只是总结近似的规则而已
                float2 offset_Normal = tangentNormal.xy * _Distortion;
                i.grabPos.xy = offset_Normal + i.grabPos.z + i.grabPos.xy;
                //自定义折射规则
                //fixed offset = (1- _RefractAmount) * 0.1f;
                //i.grabPos.xy = i.grabPos.xy - offset;
                //采样抓取屏幕的颜色纹理 其实就是映射他罩着里面内容的颜色
                //先利用透视除法 将物体的屏幕坐标变为0-1范围
                fixed2 screenUV = i.grabPos.xy / i.grabPos.w;
                fixed4 grabColor = tex2D(_GrabTexture, screenUV);
                //0 代表完全反射 1代表完全折射(透明)
                return reflectColor * (1 - _RefractAmount) + grabColor * _RefractAmount;  
            }
            ENDCG
        }
    }
}
